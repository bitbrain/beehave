class_name GdUnitObjectAssertImpl
extends GdUnitObjectAssert

var _base :GdUnitAssert


func _init(current, expect_result :int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if current is ValueProvider or current == null:
		return
	if _base.__validate_value_type(current, TYPE_BOOL)\
		or _base.__validate_value_type(current, TYPE_INT)\
		or _base.__validate_value_type(current, TYPE_FLOAT)\
		or _base.__validate_value_type(current, TYPE_STRING):
			report_error("GdUnitObjectAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func __current() -> Variant:
	return _base.__current()


func report_success() -> GdUnitObjectAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitObjectAssert:
	_base.report_error(error)
	return self


# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitObjectAssert:
	_base.has_failure_message(expected)
	return self


func starts_with_failure_message(expected: String) -> GdUnitObjectAssert:
	_base.starts_with_failure_message(expected)
	return self


func override_failure_message(message :String) -> GdUnitObjectAssert:
	_base.override_failure_message(message)
	return self


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


# Verifies that the current value is equal to expected one.
func is_equal(expected) -> GdUnitObjectAssert:
	_base.is_equal(expected)
	return self


# Verifies that the current value is not equal to expected one.
func is_not_equal(expected) -> GdUnitObjectAssert:
	_base.is_not_equal(expected)
	return self


# Verifies that the current value is null.
func is_null() -> GdUnitObjectAssert:
	_base.is_null()
	return self


# Verifies that the current value is not null.
func is_not_null() -> GdUnitObjectAssert:
	_base.is_not_null()
	return self


# Verifies that the current value is the same as the given one.
@warning_ignore("shadowed_global_identifier")
func is_same(expected) -> GdUnitObjectAssert:
	var current :Variant = __current()
	if not is_same(current, expected):
		report_error(GdAssertMessages.error_is_same(current, expected))
		return self
	report_success()
	return self


# Verifies that the current value is not the same as the given one.
func is_not_same(expected) -> GdUnitObjectAssert:
	var current = __current()
	if is_same(current, expected):
		report_error(GdAssertMessages.error_not_same(current, expected))
		return self
	report_success()
	return self


# Verifies that the current value is an instance of the given type.
func is_instanceof(type :Object) -> GdUnitObjectAssert:
	var current :Object = __current()
	if not is_instance_of(current, type):
		var result_expected: = GdObjects.extract_class_name(type)
		var result_current: = GdObjects.extract_class_name(current)
		report_error(GdAssertMessages.error_is_instanceof(result_current, result_expected))
		return self
	report_success()
	return self


# Verifies that the current value is not an instance of the given type.
func is_not_instanceof(type) -> GdUnitObjectAssert:
	var current :Variant = __current()
	if is_instance_of(current, type):
		var result: = GdObjects.extract_class_name(type)
		if result.is_success():
			report_error("Expected not be a instance of <%s>" % result.value())
		else:
			push_error("Internal ERROR: %s" % result.error_message())
		return self
	report_success()
	return self
