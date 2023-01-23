class_name GdUnitObjectInteractions
extends RefCounted

static func verify(obj :Object, times, expect_result :int):
	if not _is_mock_or_spy( obj, "__verify"):
		return obj
	return obj.__do_verify_interactions(times, expect_result)

static func verify_no_interactions(caller :Object, obj :Object, expect_result :int) -> GdUnitAssert:
	var gd_assert := GdUnitAssertImpl.new(caller, "", expect_result)
	if not _is_mock_or_spy( obj, "__verify"):
		return gd_assert.report_success()
	var summary :Dictionary = obj.__verify_no_interactions()
	if summary.is_empty():
		return gd_assert.report_success()
	return gd_assert.report_error(GdAssertMessages.error_no_more_interactions(summary))

static func verify_no_more_interactions(caller :Object, obj :Object, expect_result :int) -> GdUnitAssert:
	var gd_assert := GdUnitAssertImpl.new(caller, "", expect_result)
	if not _is_mock_or_spy( obj, "__verify_no_more_interactions"):
		return gd_assert
	var summary :Dictionary = obj.__verify_no_more_interactions()
	if summary.is_empty():
		return gd_assert
	return gd_assert.report_error(GdAssertMessages.error_no_more_interactions(summary))

static func reset(obj :Object) -> Object:
	if not _is_mock_or_spy( obj, "__reset"):
		return obj
	obj.__reset_interactions()
	return obj

static func _is_mock_or_spy(obj :Object, func_sig :String) -> bool:
	if obj is GDScript and not obj.get_script().has_script_method(func_sig):
		push_error("Error: You try to use a non mock or spy!")
		return false
	return true
