class_name GdUnitReportSummary
extends RefCounted

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

const CHARACTERS_TO_ENCODE := {
	'<' : '&lt;',
	'>' : '&gt;'
}

var _resource_path :String
var _name :String
var _test_count := 0
var _failure_count := 0
var _error_count := 0
var _orphan_count := 0
var _skipped_count := 0
var _duration := 0
var _reports :Array[GdUnitReportSummary] = []


func name() -> String:
	return html_encode(_name)


func path() -> String:
	return _resource_path.get_base_dir().replace("res://", "")


func resource_path() -> String:
	return _resource_path


func suite_count() -> int:
	return _reports.size()


func test_count() -> int:
	var count := _test_count
	for report in _reports:
		count += report.test_count()
	return count


func error_count() -> int:
	var count := _error_count
	for report in _reports:
		count += report.error_count()
	return count


func failure_count() -> int:
	var count := _failure_count
	for report in _reports:
		count += report.failure_count()
	return count


func skipped_count() -> int:
	var count := _skipped_count
	for report in _reports:
		count += report.skipped_count()
	return count


func orphan_count() -> int:
	var count := _orphan_count
	for report in _reports:
		count += report.orphan_count()
	return count


func duration() -> int:
	var count := _duration
	for report in _reports:
		count += report.duration()
	return count


func reports() -> Array:
	return _reports


func add_report(report :GdUnitReportSummary) -> void:
	_reports.append(report)


func report_state() -> String:
	return calculate_state(error_count(), failure_count(), orphan_count())


func succes_rate() -> String:
	return calculate_succes_rate(test_count(), error_count(), failure_count())


func calculate_state(p_error_count :int, p_failure_count :int, p_orphan_count :int) -> String:
	if p_error_count > 0:
		return "error"
	if p_failure_count > 0:
		return "failure"
	if p_orphan_count > 0:
		return "warning"
	return "success"


func calculate_succes_rate(p_test_count :int, p_error_count :int, p_failure_count :int) -> String:
	if p_failure_count == 0:
		return "100%"
	var count = p_test_count-p_failure_count-p_error_count
	if count < 0:
		return "0%"
	return "%d" % (( 0 if count < 0 else count) * 100.0 / p_test_count) + "%"


func create_summary(_report_dir :String) -> String:
	return ""


func html_encode(value :String) -> String:
	for key in CHARACTERS_TO_ENCODE.keys():
		value =value.replace(key, CHARACTERS_TO_ENCODE[key])
	return value


func convert_rtf_to_html(bbcode :String) -> String:
	var as_text: = GdUnitTools.richtext_normalize(bbcode)
	var converted := PackedStringArray()
	var lines := as_text.split("\n")
	for line in lines:
		converted.append("<p>%s</p>" % line)
	return "\n".join(converted)
