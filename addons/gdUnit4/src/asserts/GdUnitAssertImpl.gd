extends GdUnitAssert


var _current :Variant
var _current_error_message :String = ""
var _custom_failure_message :String = ""


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
	GdAssertReports.report_success()
	return self


func report_error(error_message :String, failure_line_number: int = -1) -> GdUnitAssert:
	var line_number := failure_line_number if failure_line_number != -1 else GdUnitAssert._get_line_number()
	GdAssertReports.set_last_error_line_number(line_number)
	_current_error_message = error_message if _custom_failure_message.is_empty() else _custom_failure_message
	GdAssertReports.report_error(_current_error_message, line_number)
	return self


func test_fail():
	return report_error(GdAssertMessages.error_not_implemented())


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
