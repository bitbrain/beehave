extends GdUnitStringAssert

var _base :GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if current != null and typeof(current) != TYPE_STRING and typeof(current) != TYPE_STRING_NAME:
		report_error("GdUnitStringAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func failure_message() -> String:
	return _base._current_error_message


func current_value():
	var current = _base.current_value()
	if current == null:
		return null
	return current as String


func report_success() -> GdUnitStringAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitStringAssert:
	_base.report_error(error)
	return self


func override_failure_message(message :String) -> GdUnitStringAssert:
	_base.override_failure_message(message)
	return self


func is_null() -> GdUnitStringAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitStringAssert:
	_base.is_not_null()
	return self


func is_equal(expected) -> GdUnitStringAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_equal(current, expected))
	if not GdObjects.equals(current, expected):
		var diffs := GdDiffTool.string_diff(current, expected)
		var formatted_current := GdAssertMessages.colored_array_div(diffs[1])
		return report_error(GdAssertMessages.error_equal(formatted_current, expected))
	return report_success()


func is_equal_ignoring_case(expected) -> GdUnitStringAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_equal_ignoring_case(current, expected))
	if not GdObjects.equals(current, expected, true):
		var diffs := GdDiffTool.string_diff(current, expected)
		var formatted_current := GdAssertMessages.colored_array_div(diffs[1])
		return report_error(GdAssertMessages.error_equal_ignoring_case(formatted_current, expected))
	return report_success()


func is_not_equal(expected) -> GdUnitStringAssert:
	var current = current_value()
	if GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()


func is_not_equal_ignoring_case(expected) -> GdUnitStringAssert:
	var current = current_value()
	if GdObjects.equals(current, expected, true):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()


func is_empty() -> GdUnitStringAssert:
	var current = current_value()
	if current == null or not current.is_empty():
		return report_error(GdAssertMessages.error_is_empty(current))
	return report_success()


func is_not_empty() -> GdUnitStringAssert:
	var current = current_value()
	if current == null or current.is_empty():
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()


func contains(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current == null or current.find(expected) == -1:
		return report_error(GdAssertMessages.error_contains(current, expected))
	return report_success()


func not_contains(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current != null and current.find(expected) != -1:
		return report_error(GdAssertMessages.error_not_contains(current, expected))
	return report_success()


func contains_ignoring_case(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current == null or current.findn(expected) == -1:
		return report_error(GdAssertMessages.error_contains_ignoring_case(current, expected))
	return report_success()


func not_contains_ignoring_case(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current != null and current.findn(expected) != -1:
		return report_error(GdAssertMessages.error_not_contains_ignoring_case(current, expected))
	return report_success()


func starts_with(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current == null or current.find(expected) != 0:
		return report_error(GdAssertMessages.error_starts_with(current, expected))
	return report_success()


func ends_with(expected :String) -> GdUnitStringAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_ends_with(current, expected))
	var find = current.length() - expected.length()
	if current.rfind(expected) != find:
		return report_error(GdAssertMessages.error_ends_with(current, expected))
	return report_success()


# gdlint:disable=max-returns
func has_length(expected :int, comparator :int = Comparator.EQUAL) -> GdUnitStringAssert:
	var current = current_value()
	if current == null:
		return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
	match comparator:
		Comparator.EQUAL:
			if current.length() != expected:
				return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
		Comparator.LESS_THAN:
			if current.length() >= expected:
				return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
		Comparator.LESS_EQUAL:
			if current.length() > expected:
				return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
		Comparator.GREATER_THAN:
			if current.length() <= expected:
				return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
		Comparator.GREATER_EQUAL:
			if current.length() < expected:
				return report_error(GdAssertMessages.error_has_length(current, expected, comparator))
		_:
			return report_error("Comparator '%d' not implemented!" % comparator)
	return report_success()
