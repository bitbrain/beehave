class_name GdAssertReports
extends RefCounted

const LAST_ERROR = "last_assert_error_message"
const LAST_ERROR_LINE = "last_assert_error_line"

# if a test success but we expect to fail map to an error
static func report_success(gd_assert :GdUnitAssert) -> GdUnitAssert:
	Engine.remove_meta(LAST_ERROR)
	if not gd_assert._expect_fail || gd_assert._is_failed:
		return gd_assert
	var error_msg := GdAssertMessages._error("Expecting to fail!")
	gd_assert.send_report(GdUnitReport.new().create(GdUnitReport.SUCCESS, gd_assert._get_line_number(), error_msg))
	return gd_assert

static func report_warning(gd_assert :GdUnitAssert, message :String, line_number :int) -> GdUnitAssert:
	gd_assert.send_report(GdUnitReport.new().create(GdUnitReport.WARN, line_number, message))
	return gd_assert

static func report_error(message:String, gd_assert :GdUnitAssert, line_number :int) -> GdUnitAssert:
	if gd_assert != null:
		gd_assert._is_failed = true
		gd_assert._current_error_message = message
		# use this kind of hack to enable validate error message for expected failure testing
		Engine.set_meta(LAST_ERROR, message)
		# reset we expect to fail
		expect_fail(false)
		# if we expect to fail we handle as success test
		if gd_assert._expect_fail:
			return gd_assert
	gd_assert.send_report(GdUnitReport.new().create(GdUnitReport.FAILURE, line_number, message))
	return gd_assert

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
