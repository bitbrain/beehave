# collects all reports seperated as warnings and failures/errors
class_name GdUnitReportCollector
extends RefCounted

const STAGE_TEST_SUITE_BEFORE = 1
const STAGE_TEST_SUITE_AFTER = 2
const STAGE_TEST_CASE_BEFORE = 4
const STAGE_TEST_CASE_EXECUTE = 8
const STAGE_TEST_CASE_AFTER = 16

var ALL_REPORT_STATES := [STAGE_TEST_SUITE_BEFORE, STAGE_TEST_SUITE_AFTER, STAGE_TEST_CASE_BEFORE, STAGE_TEST_CASE_EXECUTE, STAGE_TEST_CASE_AFTER]
var _current_stage :int
var _consume_reports := true


var _reports_by_state :Dictionary = {
	STAGE_TEST_SUITE_BEFORE : [] as Array[GdUnitReport],
	STAGE_TEST_SUITE_AFTER : [] as Array[GdUnitReport],
	STAGE_TEST_CASE_BEFORE : [] as Array[GdUnitReport],
	STAGE_TEST_CASE_AFTER : [] as Array[GdUnitReport],
	STAGE_TEST_CASE_EXECUTE : [] as Array[GdUnitReport],
}


func _init():
	GdUnitSignals.instance().gdunit_report.connect(consume)


func get_reports_by_state(execution_state :int) -> Array[GdUnitReport]:
	return _reports_by_state.get(execution_state)


func add_report(execution_state :int, report :GdUnitReport) -> void:
	get_reports_by_state(execution_state).append(report)


func push_front(execution_state :int, report :GdUnitReport) -> void:
	get_reports_by_state(execution_state).push_front(report)


func pop_front(execution_state :int) -> GdUnitReport:
	return get_reports_by_state(execution_state).pop_front()


func clear_reports(execution_states :int) -> void:
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			get_reports_by_state(state).clear()


func get_reports(execution_states :int) -> Array[GdUnitReport]:
	var reports :Array[GdUnitReport] = []
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			GdUnitTools.append_array(reports, get_reports_by_state(state))
	return reports


func has_errors(execution_states :int) -> bool:
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			for report in get_reports_by_state(state):
				if report.is_error():
					return true
	return false


func count_errors(execution_states :int) -> int:
	var count := 0
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			for report in get_reports_by_state(state):
				if report.is_error():
					count += 1
	return count


func has_failures(execution_states :int) -> bool:
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			for report in get_reports_by_state(state):
				if report.type() == GdUnitReport.FAILURE:
					return true
	return false


func count_failures(execution_states :int) -> int:
	var count := 0
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			for report in get_reports_by_state(state):
				if report.type() == GdUnitReport.FAILURE:
					count += 1
	return count


func has_warnings(execution_states :int) -> bool:
	for state in ALL_REPORT_STATES:
		if execution_states&state == state:
			for report in get_reports_by_state(state):
				if report.type() == GdUnitReport.WARN:
					return true
	return false


func set_stage(stage :int) -> void:
	_current_stage = stage



# we need to disable report collection for testing purposes
func set_consume_reports(enabled :bool) -> void:
	_consume_reports = enabled


func consume(report :GdUnitReport) -> void:
	if _consume_reports:
		add_report(_current_stage, report)
