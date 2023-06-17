class_name GdUnitFailureAssertImpl
extends GdUnitFailureAssert

var _gdunit_signals := GdUnitSignals.instance()
var _current :GdUnitAssert
var _is_failed := false
var _failure_message :String


func _init(assertion :Callable):
	# do not report any failure from the original assertion we want to test
	GdAssertReports.expect_fail(true)
	var thread_context := GdUnitThreadManager.get_current_context()
	thread_context.set_assert(null)
	GdUnitSignals.instance().gdunit_set_test_failed.connect(_on_test_failed)
	
	# execute the given assertion as callable
	assertion.call()
	GdAssertReports.expect_fail(false)
	# get the assert instance from current tread context
	_current = thread_context.get_assert()
	if not is_instance_of(_current, GdUnitAssert):
		_is_failed = true
		_failure_message = "Invalid Callable! It must be a callable of 'GdUnitAssert'"
		return
	_failure_message = _current._failure_message()


func _on_test_failed(value :bool) -> void:
	_is_failed = value


@warning_ignore("unused_parameter")
func is_equal(expected :GdUnitAssert) -> GdUnitFailureAssert:
	return _report_error("Not implemented")


@warning_ignore("unused_parameter")
func is_not_equal(expected :GdUnitAssert) -> GdUnitFailureAssert:
	return _report_error("Not implemented")


func is_null() -> GdUnitFailureAssert:
	return _report_error("Not implemented")


func is_not_null() -> GdUnitFailureAssert:
	return _report_error("Not implemented")


func is_success() -> GdUnitFailureAssert:
	if _is_failed:
		return _report_error("Expect: assertion ends successfully.")
	return self


func is_failed() -> GdUnitFailureAssert:
	if not _is_failed:
		return _report_error("Expect: assertion fails.")
	return self


func has_line(expected :int) -> GdUnitFailureAssert:
	var current := GdAssertReports.get_last_error_line_number()
	if current != expected:
		return _report_error("Expect: to failed on line '%d'\n but was '%d'." % [expected, current])
	return self


func has_message(expected :String) -> GdUnitFailureAssert:
	var expected_error := GdUnitTools.normalize_text(expected)
	var current_error := GdUnitAssertImpl._normalize_bbcode(_failure_message)
	if current_error != expected_error:
		var diffs := GdDiffTool.string_diff(current_error, expected_error)
		var current := GdAssertMessages._colored_array_div(diffs[1])
		_report_error(GdAssertMessages.error_not_same_error(current, expected_error))
	return self


func starts_with_message(expected :String) -> GdUnitFailureAssert:
	var expected_error := GdUnitTools.normalize_text(expected)
	var current_error := GdUnitAssertImpl._normalize_bbcode(_failure_message)
	if current_error.find(expected_error) != 0:
		var diffs := GdDiffTool.string_diff(current_error, expected_error)
		var current := GdAssertMessages._colored_array_div(diffs[1])
		_report_error(GdAssertMessages.error_not_same_error(current, expected_error))
	return self


func _report_error(error_message :String, failure_line_number: int = -1) -> GdUnitAssert:
	var line_number := failure_line_number if failure_line_number != -1 else GdUnitAssertImpl._get_line_number()
	GdAssertReports.set_last_error_line_number(line_number)
	GdUnitSignals.instance().gdunit_set_test_failed.emit(true)
	_send_report(GdUnitReport.new().create(GdUnitReport.FAILURE, line_number, error_message))
	return self


func _report_success() -> GdUnitFailureAssert:
	GdAssertReports.set_last_error_line_number(-1)
	GdUnitSignals.instance().gdunit_set_test_failed.emit(false)
	return self


func _send_report(report :GdUnitReport)-> void:
	_gdunit_signals.gdunit_report.emit(report)
