class_name _TestCase
extends Node

signal completed()

# default timeout 5min
const DEFAULT_TIMEOUT := -1
const ARGUMENT_TIMEOUT := "timeout"

var _iterations: int = 1
var _current_iteration :int = -1
var _seed: int
var _fuzzers: Array[GdFunctionArgument] = []
var _test_parameters := Array()
var _test_param_index := -1
var _line_number: int = -1
var _script_path: String
var _skipped := false
var _skip_info := ""
var _expect_to_interupt := false
var _timer : Timer
var _interupted :bool = false
var _failed := false
var _timeout :int
var _report :GdUnitReport = null


var monitor : GodotGdErrorMonitor = null:
	set (value):
		monitor = value
	get:
		if monitor == null:
			monitor = GodotGdErrorMonitor.new()
		return monitor


@warning_ignore("shadowed_variable_base_class")
func configure(p_name: String, p_line_number: int, p_script_path: String, p_timeout :int = DEFAULT_TIMEOUT, p_fuzzers :Array = [], p_iterations: int = 1, p_seed :int = -1) -> _TestCase:
	set_name(p_name)
	_line_number = p_line_number
	_fuzzers = p_fuzzers
	_iterations = p_iterations
	_seed = p_seed
	_script_path = p_script_path
	_timeout = p_timeout if p_timeout != DEFAULT_TIMEOUT else GdUnitSettings.test_timeout()
	return self


func execute(p_test_parameter := Array(), p_iteration := 0):
	_failure_received(false)
	_current_iteration = p_iteration - 1
	if p_iteration == 0:
		_set_failure_handler()
		set_timeout()
	monitor.start()
	if not p_test_parameter.is_empty():
		update_fuzzers(p_test_parameter, p_iteration)
		_execute_test_case(name, p_test_parameter) 
	else:
		_execute_test_case(name, [])
	await completed
	monitor.stop()
	for report_ in monitor.reports():
		if report_.is_error():
			_report = report_
			_interupted = true


func dispose():
	# unreference last used assert form the test to prevent memory leaks
	GdUnitThreadManager.get_current_context().set_assert(null)
	stop_timer()
	_remove_failure_handler()
	_fuzzers.clear()


@warning_ignore("shadowed_variable_base_class", "redundant_await")
func _execute_test_case(name :String, test_parameter :Array):
	# needs at least on await otherwise it braks the awaiting chain
	await get_parent().callv(name, test_parameter)
	await get_tree().create_timer(0.0001).timeout
	completed.emit()


func update_fuzzers(input_values :Array, iteration :int):
	for fuzzer in input_values:
		if fuzzer is Fuzzer:
			fuzzer._iteration_index = iteration + 1


func set_timeout():
	var time :float = _timeout * 0.001
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_name("gdunit_test_case_timer_%d" % _timer.get_instance_id())
	_timer.timeout.connect(func do_interrupt():
		if has_fuzzer():
			_report = GdUnitReport.new().create(GdUnitReport.INTERUPTED, line_number(), GdAssertMessages.fuzzer_interuped(_current_iteration, "timedout"))
		else:
			_report = GdUnitReport.new().create(GdUnitReport.INTERUPTED, line_number(), GdAssertMessages.test_timeout(timeout()))
		_interupted = true
		completed.emit()
		, CONNECT_REFERENCE_COUNTED)
	_timer.set_one_shot(true)
	_timer.set_wait_time(time)
	_timer.set_autostart(false)
	_timer.start()


func _set_failure_handler() -> void:
	if not GdUnitSignals.instance().gdunit_set_test_failed.is_connected(_failure_received):
		GdUnitSignals.instance().gdunit_set_test_failed.connect(_failure_received)


func _remove_failure_handler() -> void:
	if GdUnitSignals.instance().gdunit_set_test_failed.is_connected(_failure_received):
		GdUnitSignals.instance().gdunit_set_test_failed.disconnect(_failure_received)
	

func _failure_received(is_failed :bool) -> void:
	# is already failed?
	if _failed:
		return
	_failed = is_failed
	Engine.set_meta("GD_TEST_FAILURE", is_failed)


func stop_timer() :
	# finish outstanding timeouts
	if is_instance_valid(_timer):
		_timer.stop()
		_timer.call_deferred("free")


func expect_to_interupt() -> void:
	_expect_to_interupt = true


func is_interupted() -> bool:
	return _interupted


func is_expect_interupted() -> bool:
	return _expect_to_interupt


func is_parameterized() -> bool:
	return _test_parameters.size() != 0


func is_skipped() -> bool:
	return _skipped


func report() -> GdUnitReport:
	return _report


func skip_info() -> String:
	return _skip_info

func line_number() -> int:
	return _line_number


func iterations() -> int:
	return _iterations


func timeout() -> int:
	return _timeout


func seed_value() -> int:
	return _seed


func has_fuzzer() -> bool:
	return not _fuzzers.is_empty()


func fuzzer_arguments() -> Array[GdFunctionArgument]:
	return _fuzzers


func script_path() -> String:
	return _script_path


func ResourcePath() -> String:
	return _script_path


func generate_seed() -> void:
	if _seed != -1:
		seed(_seed)


func skip(skipped :bool, error :String = "") -> void:
	_skipped = skipped
	_skip_info = error


func set_test_parameters(p_test_parameters :Array) -> void:
	_test_parameters = p_test_parameters


func set_test_parameter_index(index :int) -> void:
	_test_param_index = index


func test_parameters() -> Array:
	return _test_parameters


func test_parameter_index() -> int:
	return _test_param_index


func test_case_names() -> PackedStringArray:
	var test_cases :=  PackedStringArray()
	var test_name = get_name()
	for index in _test_parameters.size():
		test_cases.append("%s:%d %s" % [test_name, index, str(_test_parameters[index]).replace('"', "'")])
	return test_cases


func _to_string():
	return "%s :%d (%dms)" % [get_name(), _line_number, _timeout]
