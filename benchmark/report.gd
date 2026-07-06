## Renders benchmark results as JSON, markdown tables and SVG bar charts.
extends RefCounted

const TEXT_COLOR := "#8b8b8b"
const BAR_COLOR := "#f7b900"
const ROW_HEIGHT := 30
const LABEL_WIDTH := 250
const BAR_AREA_WIDTH := 360
const VALUE_WIDTH := 130


static func write(results: Dictionary, directory: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	_write_text("%s/results.json" % directory, JSON.stringify(results, "\t"))
	_write_text("%s/results.md" % directory, _render_markdown(results))
	for suite in results.suites:
		_write_text("%s/%s.svg" % [directory, suite.name], _render_chart(suite))


static func format_value(value: float, case_result: Dictionary) -> String:
	var scaled: float = value / case_result.unit_divisor
	var precision := 3
	if scaled >= 100.0:
		precision = 0
	elif scaled >= 10.0:
		precision = 1
	elif scaled >= 1.0:
		precision = 2
	return "%.*f %s" % [precision, scaled, case_result.unit]


static func _write_text(path: String, contents: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(contents)
	file.close()


static func _render_markdown(results: Dictionary) -> String:
	var lines: Array[String] = ["# Beehave Benchmark Results", ""]
	var meta: Dictionary = results.meta
	lines.append(
		"`%s` | Beehave `%s` | Godot `%s` (%s build) | %s | %s (%d threads)"
		% [meta.date, meta.beehave, meta.godot, meta.build, meta.os, meta.cpu, meta.threads]
	)
	lines.append("")
	lines.append("All values are per workload invocation. Lower is better. See")
	lines.append("[the methodology](../README.md) for details on how these are measured.")
	for suite in results.suites:
		lines.append("")
		lines.append("## %s" % suite.title)
		lines.append("")
		lines.append_array(_render_table(suite))
	lines.append("")
	return "\n".join(lines)


static func _render_table(suite: Dictionary) -> Array[String]:
	var has_relative: bool = suite.cases.any(
		func(case_result: Dictionary) -> bool: return not case_result.relative_to.is_empty()
	)
	var header := "| Case | Median | Mean | P95 | P99 | CoV |"
	var separator := "|---|---:|---:|---:|---:|---:|"
	if has_relative:
		header += " Overhead |"
		separator += "---:|"
	var lines: Array[String] = [header, separator]
	for case_result in suite.cases:
		var stats: Dictionary = case_result.stats
		var row := (
			"| %s | %s | %s | %s | %s | %.1f%% |"
			% [
				case_result.name,
				format_value(stats.median, case_result),
				format_value(stats.mean, case_result),
				format_value(stats.p95, case_result),
				format_value(stats.p99, case_result),
				stats.cov * 100.0,
			]
		)
		if has_relative:
			row += " %s |" % _render_relative(suite, case_result)
		lines.append(row)
	return lines


static func _render_relative(suite: Dictionary, case_result: Dictionary) -> String:
	if case_result.relative_to.is_empty():
		return "—"
	for other in suite.cases:
		if other.name == case_result.relative_to and other.stats.median > 0.0:
			return "%.1f×" % (case_result.stats.median / other.stats.median)
	return "—"


static func _render_chart(suite: Dictionary) -> String:
	var width := LABEL_WIDTH + BAR_AREA_WIDTH + VALUE_WIDTH
	var height: int = suite.cases.size() * ROW_HEIGHT + 50
	var max_median := 0.0
	for case_result in suite.cases:
		max_median = max(max_median, case_result.stats.median)
	var lines: Array[String] = [
		(
			'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" font-family="system-ui, sans-serif" font-size="13">'
			% [width, height]
		),
		(
			'<text x="8" y="24" fill="%s" font-size="15" font-weight="bold">%s — median, lower is better</text>'
			% [TEXT_COLOR, suite.title.xml_escape()]
		),
	]
	var y := 40
	for case_result in suite.cases:
		var bar_width: int = max(2, roundi(case_result.stats.median / max_median * BAR_AREA_WIDTH))
		var center := y + ROW_HEIGHT / 2.0 + 4
		lines.append(
			'<text x="%d" y="%.0f" fill="%s" text-anchor="end">%s</text>'
			% [LABEL_WIDTH - 10, center, TEXT_COLOR, str(case_result.name).xml_escape()]
		)
		lines.append(
			'<rect x="%d" y="%d" width="%d" height="%d" rx="3" fill="%s"/>'
			% [LABEL_WIDTH, y + 7, bar_width, ROW_HEIGHT - 14, BAR_COLOR]
		)
		lines.append(
			'<text x="%d" y="%.0f" fill="%s">%s</text>'
			% [
				LABEL_WIDTH + bar_width + 8,
				center,
				TEXT_COLOR,
				format_value(case_result.stats.median, case_result),
			]
		)
		y += ROW_HEIGHT
	lines.append("</svg>")
	return "\n".join(lines)
