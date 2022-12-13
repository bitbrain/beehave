# collects all reports seperated as warnings and failures/errors
class_name GdUnitReportCollector
extends GdUnitReportConsumer

const STAGE_TEST_SUITE_BEFORE = 1
const STAGE_TEST_SUITE_AFTER = 2
const STAGE_TEST_CASE_BEFORE = 4
const STAGE_TEST_CASE_EXECUTE = 8
const STAGE_TEST_CASE_AFTER = 16

var ALL_REPORT_STATES := [STAGE_TEST_SUITE_BEFORE, STAGE_TEST_SUITE_AFTER, STAGE_TEST_CASE_BEFORE, STAGE_TEST_CASE_EXECUTE, STAGE_TEST_CASE_AFTER]
var _current_stage :int


var _reports_by_state :Dictionary = {
	STAGE_TEST_SUITE_BEFORE : Array(),
	STAGE_TEST_SUITE_AFTER : Array(),
	STAGE_TEST_CASE_BEFORE : Array(),
	STAGE_TEST_CASE_AFTER : Array(),
	STAGE_TEST_CASE_EXECUTE : Array(),
}

func get_reports_by_state(execution_state :int) -> Array:
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

func get_reports(execution_states :int) -> Array:
	var reports :Array = Array()
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

func consume(report :GdUnitReport) -> void:
	add_report(_current_stage, report)
