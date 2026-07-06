## Discovers and runs all benchmark suites in `benchmark/suites/`, then
## writes JSON, markdown and SVG reports to `benchmark/results/`.
##
## Run headless via:
## [codeblock]
## godot --headless res://benchmark/benchmark.tscn
## [/codeblock]
## or open `benchmark.tscn` in the editor and run the scene.
extends Node

const Bench := preload("res://benchmark/bench.gd")
const Stats := preload("res://benchmark/stats.gd")
const Report := preload("res://benchmark/report.gd")

const SUITES_PATH := "res://benchmark/suites"
const RESULTS_PATH := "res://benchmark/results"

## Beehave's debugger integration attempts to send `EngineDebugger` messages
## when running under an editor build without an attached debugger. Every
## failed send prints an error with a full script backtrace, which would
## distort the measurements. Set to `true` when debugging benchmark suites.
const VERBOSE_ERRORS := false


func _ready() -> void:
	seed(Bench.RANDOM_SEED)
	Engine.print_error_messages = VERBOSE_ERRORS
	var results := {meta = _collect_metadata(), suites = []}
	for suite_file in DirAccess.get_files_at(SUITES_PATH):
		if not suite_file.ends_with(".gd"):
			continue
		results.suites.append(await _run_suite(suite_file))
	Engine.print_error_messages = true
	Report.write(results, RESULTS_PATH)
	print("\nResults written to %s" % ProjectSettings.globalize_path(RESULTS_PATH))
	# let queued frees flush before quitting to avoid leak warnings on exit
	await get_tree().process_frame
	get_tree().quit()


func _run_suite(suite_file: String) -> Dictionary:
	var suite: Node = load("%s/%s" % [SUITES_PATH, suite_file]).new()
	add_child(suite)
	var suite_result := {
		name = suite_file.get_basename(),
		title = suite.title(),
		cases = [],
	}
	print("\n=== %s ===" % suite.title())
	for method in suite.get_method_list():
		if not method.name.begins_with("benchmark_"):
			continue
		var returned: Variant = suite.call(method.name)
		var cases: Array = returned if returned is Array else [returned]
		for case_config in cases:
			if not case_config.has("name"):
				case_config.name = String(method.name).trim_prefix("benchmark_")
			suite_result.cases.append(await _run_case(case_config))
	suite.queue_free()
	return suite_result


func _run_case(case_config: Dictionary) -> Dictionary:
	if case_config.node != null:
		add_child(case_config.node)
		await get_tree().process_frame
	if case_config.has("setup"):
		case_config.setup.call()

	var workload: Callable = case_config.workload
	for i in case_config.warmup:
		workload.call()
		if case_config.per_frame:
			await get_tree().process_frame

	var samples: Array[float] = []
	for batch in case_config.batches:
		var start := Time.get_ticks_usec()
		for i in case_config.batch_size:
			workload.call()
		samples.append(float(Time.get_ticks_usec() - start) / case_config.batch_size)
		if case_config.per_frame:
			await get_tree().process_frame

	if case_config.node != null:
		case_config.node.queue_free()
		await get_tree().process_frame

	var case_result := {
		name = case_config.name,
		unit = case_config.unit,
		unit_divisor = case_config.unit_divisor,
		relative_to = case_config.relative_to,
		stats = Stats.summarize(samples),
	}
	# break reference cycles between the config dictionary and the
	# callables capturing it, so scripts are released on exit
	case_config.clear()
	print(
		"%s: median %s (CoV %.1f%%)"
		% [
			case_result.name,
			Report.format_value(case_result.stats.median, case_result),
			case_result.stats.cov * 100.0,
		]
	)
	return case_result


func _collect_metadata() -> Dictionary:
	var plugin := ConfigFile.new()
	plugin.load("res://addons/beehave/plugin.cfg")
	return {
		date = Time.get_date_string_from_system(),
		beehave = plugin.get_value("plugin", "version", "unknown"),
		godot = Engine.get_version_info().string,
		build = "debug" if OS.is_debug_build() else "release",
		os = "%s %s" % [OS.get_name(), OS.get_version()],
		cpu = OS.get_processor_name(),
		threads = OS.get_processor_count(),
	}
