class_name GdUnitFloatAssertImpl
extends GdUnitFloatAssert

var _base: GdUnitAssert

func _init(current, expect_result :int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if not _base.__validate_value_type(current, TYPE_FLOAT):
		report_error("GdUnitFloatAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func __current():
	return _base.__current()


func report_success() -> GdUnitFloatAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitFloatAssert:
	_base.report_error(error)
	return self


# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitFloatAssert:
	_base.has_failure_message(expected)
	return self


func starts_with_failure_message(expected: String) -> GdUnitFloatAssert:
	_base.starts_with_failure_message(expected)
	return self


func override_failure_message(message :String) -> GdUnitFloatAssert:
	_base.override_failure_message(message)
	return self


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


#-------------------------------------------------------------------------------
# Verifies that the current value is null.
func is_null() -> GdUnitFloatAssert:
	_base.is_null()
	return self


# Verifies that the current value is not null.
func is_not_null() -> GdUnitFloatAssert:
	_base.is_not_null()
	return self


# Verifies that the current value is equal to expected one.
func is_equal(expected :float) -> GdUnitFloatAssert:
	_base.is_equal(expected)
	return self


# Verifies that the current value is not equal to expected one.
func is_not_equal(expected :float) -> GdUnitFloatAssert:
	_base.is_not_equal(expected)
	return self


# Verifies that the current and expected value are approximately equal.
@warning_ignore("shadowed_global_identifier")
func is_equal_approx(expected :float, approx :float) -> GdUnitFloatAssert:
	return is_between(expected-approx, expected+approx)


# Verifies that the current value is less than the given one.
func is_less(expected :float) -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current >= expected:
		report_error(GdAssertMessages.error_is_value(Comparator.LESS_THAN, current, expected))
	return report_success()


# Verifies that the current value is less than or equal the given one.
func is_less_equal(expected :float) -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current > expected:
		report_error(GdAssertMessages.error_is_value(Comparator.LESS_EQUAL, current, expected))
	return report_success()


# Verifies that the current value is greater than the given one.
func is_greater(expected :float) -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current <= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_THAN, current, expected))
	return report_success()


# Verifies that the current value is greater than or equal the given one.
func is_greater_equal(expected :float) -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current < expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_EQUAL, current, expected))
	return report_success()


# Verifies that the current value is negative.
func is_negative() -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current >= 0.0:
		return report_error(GdAssertMessages.error_is_negative(current))
	return report_success()


# Verifies that the current value is not negative.
func is_not_negative() -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current < 0.0:
		return report_error(GdAssertMessages.error_is_not_negative(current))
	return report_success()


# Verifies that the current value is equal to zero.
func is_zero() -> GdUnitFloatAssert:
	var current = __current()
	if current == null or not is_equal_approx(0.00000000, current):
		return report_error(GdAssertMessages.error_is_zero(current))
	return report_success()


# Verifies that the current value is not equal to zero.
func is_not_zero() -> GdUnitFloatAssert:
	var current = __current()
	if current == null or is_equal_approx(0.00000000, current):
		return report_error(GdAssertMessages.error_is_not_zero())
	return report_success()


# Verifies that the current value is in the given set of values.
func is_in(expected :Array) -> GdUnitFloatAssert:
	var current = __current()
	if not expected.has(current):
		return report_error(GdAssertMessages.error_is_in(current, expected))
	return report_success()


# Verifies that the current value is not in the given set of values.
func is_not_in(expected :Array) -> GdUnitFloatAssert:
	var current = __current()
	if expected.has(current):
		return report_error(GdAssertMessages.error_is_not_in(current, expected))
	return report_success()


# Verifies that the current value is between the given boundaries (inclusive).
func is_between(from :float, to :float) -> GdUnitFloatAssert:
	var current = __current()
	if current == null or current < from or current > to:
		return report_error(GdAssertMessages.error_is_value(Comparator.BETWEEN_EQUAL, current, from, to))
	return report_success()
