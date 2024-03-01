extends GdUnitIntAssert

var _base: GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not GdUnitAssertions.validate_value_type(current, TYPE_INT):
		report_error("GdUnitIntAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func current_value() -> Variant:
	return _base.current_value()


func report_success() -> GdUnitIntAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitIntAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitIntAssert:
	_base.override_failure_message(message)
	return self


func is_null() -> GdUnitIntAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitIntAssert:
	_base.is_not_null()
	return self


func is_equal(expected :int) -> GdUnitIntAssert:
	_base.is_equal(expected)
	return self


func is_not_equal(expected :int) -> GdUnitIntAssert:
	_base.is_not_equal(expected)
	return self


func is_less(expected :int) -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current >= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_THAN, current, expected))
	return report_success()


func is_less_equal(expected :int) -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current > expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_EQUAL, current, expected))
	return report_success()


func is_greater(expected :int) -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current <= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_THAN, current, expected))
	return report_success()


func is_greater_equal(expected :int) -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current < expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_EQUAL, current, expected))
	return report_success()


func is_even() -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current % 2 != 0:
		return report_error(GdAssertMessages.error_is_even(current))
	return report_success()


func is_odd() -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current % 2 == 0:
		return report_error(GdAssertMessages.error_is_odd(current))
	return report_success()


func is_negative() -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current >= 0:
		return report_error(GdAssertMessages.error_is_negative(current))
	return report_success()


func is_not_negative() -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current < 0:
		return report_error(GdAssertMessages.error_is_not_negative(current))
	return report_success()


func is_zero() -> GdUnitIntAssert:
	var current = current_value()
	if current != 0:
		return report_error(GdAssertMessages.error_is_zero(current))
	return report_success()


func is_not_zero() -> GdUnitIntAssert:
	var current = current_value()
	if current == 0:
		return report_error(GdAssertMessages.error_is_not_zero())
	return report_success()


func is_in(expected :Array) -> GdUnitIntAssert:
	var current = current_value()
	if not expected.has(current):
		return report_error(GdAssertMessages.error_is_in(current, expected))
	return report_success()


func is_not_in(expected :Array) -> GdUnitIntAssert:
	var current = current_value()
	if expected.has(current):
		return report_error(GdAssertMessages.error_is_not_in(current, expected))
	return report_success()


func is_between(from :int, to :int) -> GdUnitIntAssert:
	var current = current_value()
	if current == null or current < from or current > to:
		return report_error(GdAssertMessages.error_is_value(Comparator.BETWEEN_EQUAL, current, from, to))
	return report_success()
