class_name GdUnitAssertImpl
extends GdUnitAssert


var _current :Variant
var _current_error_message :String = ""
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


func _init(current :Variant):
	_current = current
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	GdAssertReports.reset_last_error_line_number()


func _failure_message() -> String:
	return _current_error_message


func __current() -> Variant:
	return _current


func __validate_value_type(value, type :Variant.Type) -> bool:
	return value == null or typeof(value) == type


func report_success() -> GdUnitAssert:
	GdAssertReports.report_success(GdUnitAssertImpl._get_line_number())
	return self


func report_error(error_message :String, failure_line_number: int = -1) -> GdUnitAssert:
	var line_number := failure_line_number if failure_line_number != -1 else GdUnitAssertImpl._get_line_number()
	GdAssertReports.set_last_error_line_number(line_number)
	_current_error_message = error_message if _custom_failure_message.is_empty() else _custom_failure_message
	GdAssertReports.report_error(_current_error_message, line_number)
	return self


func test_fail():
	return report_error(GdAssertMessages.error_not_implemented())


static func _normalize_bbcode(message :String) -> String:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.append_text(message if message else "")
	var normalized = rtl.get_parsed_text()
	rtl.free()
	return normalized.replace("\r", "")


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
