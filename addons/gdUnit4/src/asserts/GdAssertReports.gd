class_name GdAssertReports
extends RefCounted

const LAST_ERROR = "last_assert_error_message"
const LAST_ERROR_LINE = "last_assert_error_line"


static func report_success() -> void:
	GdUnitSignals.instance().gdunit_set_test_failed.emit(false)
	GdAssertReports.set_last_error_line_number(-1)
	Engine.remove_meta(LAST_ERROR)


static func report_warning(message :String, line_number :int) -> void:
	GdUnitSignals.instance().gdunit_set_test_failed.emit(false)
	send_report(GdUnitReport.new().create(GdUnitReport.WARN, line_number, message))


static func report_error(message:String, line_number :int) -> void:
	GdUnitSignals.instance().gdunit_set_test_failed.emit(true)
	GdAssertReports.set_last_error_line_number(line_number)
	Engine.set_meta(LAST_ERROR, message)
	# if we expect to fail we handle as success test
	if is_expect_fail():
		return
	send_report(GdUnitReport.new().create(GdUnitReport.FAILURE, line_number, message))


static func reset_last_error_line_number() -> void:
	Engine.remove_meta(LAST_ERROR_LINE)


static func set_last_error_line_number(line_number :int) -> void:
	Engine.set_meta(LAST_ERROR_LINE, line_number)


static func get_last_error_line_number() -> int:
	if Engine.has_meta(LAST_ERROR_LINE):
		return Engine.get_meta(LAST_ERROR_LINE)
	return -1


static func expect_fail(enabled :bool = true):
	Engine.set_meta("report_failures", enabled)


static func is_expect_fail() -> bool:
	if Engine.has_meta("report_failures"):
		return Engine.get_meta("report_failures")
	return false


static func current_failure() -> String:
	return Engine.get_meta(LAST_ERROR)


static func send_report(report :GdUnitReport) -> void:
	var execution_context_id := GdUnitThreadManager.get_current_context().get_execution_context_id()
	GdUnitSignals.instance().gdunit_report.emit(execution_context_id, report)
