extends GdUnitDictionaryAssert

var _base :GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not GdUnitAssertions.validate_value_type(current, TYPE_DICTIONARY):
		report_error("GdUnitDictionaryAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func report_success() -> GdUnitDictionaryAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitDictionaryAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitDictionaryAssert:
	_base.override_failure_message(message)
	return self


func current_value() -> Variant:
	return _base.current_value()


func is_null() -> GdUnitDictionaryAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitDictionaryAssert:
	_base.is_not_null()
	return self


func is_equal(expected) -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_equal(null, GdAssertMessages.format_dict(expected)))
	if not GdObjects.equals(current, expected):
		var c := GdAssertMessages.format_dict(current)
		var e := GdAssertMessages.format_dict(expected)
		var diff := GdDiffTool.string_diff(c, e)
		var curent_diff := GdAssertMessages.colored_array_div(diff[1])
		return report_error(GdAssertMessages.error_equal(curent_diff, e))
	return report_success()


func is_not_equal(expected) -> GdUnitDictionaryAssert:
	var current = current_value()
	if GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()


@warning_ignore("unused_parameter", "shadowed_global_identifier")
func is_same(expected) -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_equal(null, GdAssertMessages.format_dict(expected)))
	if not is_same(current, expected):
		var c := GdAssertMessages.format_dict(current)
		var e := GdAssertMessages.format_dict(expected)
		var diff := GdDiffTool.string_diff(c, e)
		var curent_diff := GdAssertMessages.colored_array_div(diff[1])
		return report_error(GdAssertMessages.error_is_same(curent_diff, e))
	return report_success()


@warning_ignore("unused_parameter", "shadowed_global_identifier")
func is_not_same(expected) -> GdUnitDictionaryAssert:
	var current = current_value()
	if is_same(current, expected):
		return report_error(GdAssertMessages.error_not_same(current, expected))
	return report_success()


func is_empty() -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null or not current.is_empty():
		return report_error(GdAssertMessages.error_is_empty(current))
	return report_success()


func is_not_empty() -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null or current.is_empty():
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()


func has_size(expected: int) -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	if current.size() != expected:
		return report_error(GdAssertMessages.error_has_size(current, expected))
	return report_success()


func _contains_keys(expected :Array, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	# find expected keys
	var keys_not_found :Array = expected.filter(_filter_by_key.bind(current.keys(), compare_mode))
	if not keys_not_found.is_empty():
		return report_error(GdAssertMessages.error_contains_keys(current.keys(), expected, keys_not_found, compare_mode))
	return report_success()


func _contains_key_value(key, value, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitDictionaryAssert:
	var current = current_value()
	var expected := [key]
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	var keys_not_found :Array = expected.filter(_filter_by_key.bind(current.keys(), compare_mode))
	if not keys_not_found.is_empty():
		return report_error(GdAssertMessages.error_contains_key_value(key, value, current.keys(), compare_mode))
	if not GdObjects.equals(current[key], value, false, compare_mode):
		return report_error(GdAssertMessages.error_contains_key_value(key, value, current[key], compare_mode))
	return report_success()


func _not_contains_keys(expected :Array, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitDictionaryAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	var keys_found :Array = current.keys().filter(_filter_by_key.bind(expected, compare_mode, true))
	if not keys_found.is_empty():
		return report_error(GdAssertMessages.error_not_contains_keys(current.keys(), expected, keys_found, compare_mode))
	return report_success()


func contains_keys(expected :Array) -> GdUnitDictionaryAssert:
	return _contains_keys(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func contains_key_value(key, value) -> GdUnitDictionaryAssert:
	return _contains_key_value(key, value, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func not_contains_keys(expected :Array) -> GdUnitDictionaryAssert:
	return _not_contains_keys(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func contains_same_keys(expected :Array) -> GdUnitDictionaryAssert:
	return _contains_keys(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func contains_same_key_value(key, value) -> GdUnitDictionaryAssert:
	return _contains_key_value(key, value, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func not_contains_same_keys(expected :Array) -> GdUnitDictionaryAssert:
	return _not_contains_keys(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func _filter_by_key(element :Variant, values :Array, compare_mode :GdObjects.COMPARE_MODE, is_not :bool = false) -> bool:
	for key in values:
		if GdObjects.equals(key, element, false, compare_mode):
			return is_not
	return !is_not
