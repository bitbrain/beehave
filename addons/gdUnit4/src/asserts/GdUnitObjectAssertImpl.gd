extends GdUnitObjectAssert

var _base :GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if (current != null
		and (GdUnitAssertions.validate_value_type(current, TYPE_BOOL)
		or GdUnitAssertions.validate_value_type(current, TYPE_INT)
		or GdUnitAssertions.validate_value_type(current, TYPE_FLOAT)
		or GdUnitAssertions.validate_value_type(current, TYPE_STRING))):
			report_error("GdUnitObjectAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func current_value() -> Variant:
	return _base.current_value()


func report_success() -> GdUnitObjectAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitObjectAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitObjectAssert:
	_base.override_failure_message(message)
	return self


func is_equal(expected) -> GdUnitObjectAssert:
	_base.is_equal(expected)
	return self


func is_not_equal(expected) -> GdUnitObjectAssert:
	_base.is_not_equal(expected)
	return self


func is_null() -> GdUnitObjectAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitObjectAssert:
	_base.is_not_null()
	return self


@warning_ignore("shadowed_global_identifier")
func is_same(expected) -> GdUnitObjectAssert:
	var current :Variant = current_value()
	if not is_same(current, expected):
		report_error(GdAssertMessages.error_is_same(current, expected))
		return self
	report_success()
	return self


func is_not_same(expected) -> GdUnitObjectAssert:
	var current = current_value()
	if is_same(current, expected):
		report_error(GdAssertMessages.error_not_same(current, expected))
		return self
	report_success()
	return self


func is_instanceof(type :Object) -> GdUnitObjectAssert:
	var current :Object = current_value()
	if not is_instance_of(current, type):
		var result_expected: = GdObjects.extract_class_name(type)
		var result_current: = GdObjects.extract_class_name(current)
		report_error(GdAssertMessages.error_is_instanceof(result_current, result_expected))
		return self
	report_success()
	return self


func is_not_instanceof(type) -> GdUnitObjectAssert:
	var current :Variant = current_value()
	if is_instance_of(current, type):
		var result: = GdObjects.extract_class_name(type)
		if result.is_success():
			report_error("Expected not be a instance of <%s>" % result.value())
		else:
			push_error("Internal ERROR: %s" % result.error_message())
		return self
	report_success()
	return self
