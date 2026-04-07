extends GdUnitBoolAssert

var _base: GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not GdUnitAssertions.validate_value_type(current, TYPE_BOOL):
		report_error("GdUnitBoolAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func current_value():
	return _base.current_value()


func report_success() -> GdUnitBoolAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitBoolAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitBoolAssert:
	_base.override_failure_message(message)
	return self


# Verifies that the current value is null.
func is_null() -> GdUnitBoolAssert:
	_base.is_null()
	return self


# Verifies that the current value is not null.
func is_not_null() -> GdUnitBoolAssert:
	_base.is_not_null()
	return self


func is_equal(expected) -> GdUnitBoolAssert:
	_base.is_equal(expected)
	return self


func is_not_equal(expected) -> GdUnitBoolAssert:
	_base.is_not_equal(expected)
	return self


func is_true() -> GdUnitBoolAssert:
	if current_value() != true:
		return report_error(GdAssertMessages.error_is_true(current_value()))
	return report_success()


func is_false() -> GdUnitBoolAssert:
	if current_value() == true || current_value() == null:
		return report_error(GdAssertMessages.error_is_false(current_value()))
	return report_success()
