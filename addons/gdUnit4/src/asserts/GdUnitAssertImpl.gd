class_name GdUnitAssertImpl
extends GdUnitAssert

var _gdunit_signals := GdUnitSignals.instance()
var _current_value_provider :ValueProvider
var _is_failed :bool = false
var _current_error_message :String = ""
var _expect_fail :bool = false
var _custom_failure_message :String = ""


# Scans the current stack trace for the root cause to extract the line number
static func _get_line_number() -> int:
	var stack_trace := get_stack()
	if stack_trace == null or stack_trace.is_empty():
		return -1
	for stack_info in stack_trace:
		var function :String = stack_info.get("function")
		# we catch helper asserts to skip over to return the correct line number
		if function.begins_with("assert_"):
			continue
		var source :String = stack_info.get("source")
		if source.is_empty() \
			or source.begins_with("user://") \
			or source.ends_with("AssertImpl.gd") \
			or source.ends_with("GdUnitTestSuite.gd") \
			or source.ends_with("GdUnitSceneRunnerImpl.gd") \
			or source.ends_with("GdUnitObjectInteractions.gd") \
			or source.ends_with("GdUnitAwaiter.gd"):
			continue
		return stack_info.get("line")
	return -1


func _init(current :Variant, expect_result :int = EXPECT_SUCCESS):
	_current_value_provider = current if current is ValueProvider else DefaultValueProvider.new(current)
	GdAssertReports.reset_last_error_line_number()
	_set_test_failure(false)
	# we expect the test will fail
	if expect_result == EXPECT_FAIL or GdAssertReports.is_expect_fail():
		_expect_fail = true


func _set_test_failure(failed :bool) -> void:
	_is_failed = failed
	_gdunit_signals.gdunit_set_test_failed.emit(failed)


func __current() -> Variant:
	return _current_value_provider.get_value()


func __validate_value_type(value, type :int) -> bool:
	return value is ValueProvider or value == null or typeof(value) == type


func report_success() -> GdUnitAssert:
	return GdAssertReports.report_success(self)


func report_error(error_message :String, failure_line_number: int = -1) -> GdUnitAssert:
	_set_test_failure(true)
	var line_number := failure_line_number if failure_line_number != -1 else GdUnitAssertImpl._get_line_number()
	GdAssertReports.set_last_error_line_number(line_number)
	if _custom_failure_message.is_empty():
		return GdAssertReports.report_error(error_message, self, line_number)
	return GdAssertReports.report_error(_custom_failure_message, self, line_number)


func test_fail():
	return report_error(GdAssertMessages.error_not_implemented())


static func _normalize_bbcode(message :String) -> String:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.append_text(message if message else "")
	var normalized = rtl.get_parsed_text()
	rtl.free()
	return normalized.replace("\r", "")


func has_failure_message(expected :String):
	var expected_error := GdUnitTools.normalize_text(expected)
	var current_error := GdUnitAssertImpl._normalize_bbcode(_current_error_message)
	if current_error != expected_error:
		_expect_fail = false
		var diffs := GdDiffTool.string_diff(current_error, expected_error)
		var current := GdAssertMessages._colored_array_div(diffs[1])
		report_error(GdAssertMessages.error_not_same_error(current, expected_error))
	return self


func starts_with_failure_message(expected :String):
	var expected_error := GdUnitTools.normalize_text(expected)
	var current_error := GdUnitAssertImpl._normalize_bbcode(_current_error_message)
	if current_error.find(expected_error) != 0:
		_expect_fail = false
		var diffs := GdDiffTool.string_diff(current_error, expected_error)
		var current := GdAssertMessages._colored_array_div(diffs[1])
		report_error(GdAssertMessages.error_not_same_error(current, expected_error))
	return self


func override_failure_message(message :String):
	_custom_failure_message = message
	return self


func is_equal(expected) -> GdUnitAssert:
	var current = __current()
	if not GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_equal(current, expected))
	return report_success()


func is_not_equal(expected) -> GdUnitAssert:
	var current = __current()
	if GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()


func is_null() -> GdUnitAssert:
	var current = __current()
	if current != null:
		return report_error(GdAssertMessages.error_is_null(current))
	return report_success()


func is_not_null() -> GdUnitAssert:
	var current = __current()
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	return report_success()


func send_report(report :GdUnitReport)-> void:
	_gdunit_signals.gdunit_report.emit(report)
