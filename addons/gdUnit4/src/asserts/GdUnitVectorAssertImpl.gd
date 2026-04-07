extends GdUnitVectorAssert

var _base: GdUnitAssert
var _current_type :int


func _init(current :Variant):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not _validate_value_type(current):
		report_error("GdUnitVectorAssert error, the type <%s> is not supported." % GdObjects.typeof_as_string(current))
	_current_type = typeof(current)


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func _validate_value_type(value) -> bool:
	return (
		value == null
		or typeof(value) in [
			TYPE_VECTOR2,
			TYPE_VECTOR2I,
			TYPE_VECTOR3,
			TYPE_VECTOR3I,
			TYPE_VECTOR4,
			TYPE_VECTOR4I
		]
	)


func _validate_is_vector_type(value :Variant) -> bool:
	var type := typeof(value)
	if type == _current_type or _current_type == TYPE_NIL:
		return true
	report_error(GdAssertMessages.error_is_wrong_type(_current_type, type))
	return false


func current_value() -> Variant:
	return _base.current_value()


func report_success() -> GdUnitVectorAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitVectorAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitVectorAssert:
	_base.override_failure_message(message)
	return self


func is_null() -> GdUnitVectorAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitVectorAssert:
	_base.is_not_null()
	return self


func is_equal(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	_base.is_equal(expected)
	return self


func is_not_equal(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	_base.is_not_equal(expected)
	return self


@warning_ignore("shadowed_global_identifier")
func is_equal_approx(expected :Variant, approx :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected) or not _validate_is_vector_type(approx):
		return self
	var current = current_value()
	var from = expected - approx
	var to = expected + approx
	if current == null or (not _is_equal_approx(current, from, to)):
		return report_error(GdAssertMessages.error_is_value(Comparator.BETWEEN_EQUAL, current, from, to))
	return report_success()


func _is_equal_approx(current, from, to) -> bool:
	match typeof(current):
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return ((current.x >= from.x and current.y >= from.y)
				and (current.x <= to.x and current.y <= to.y))
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return ((current.x >= from.x and current.y >= from.y and current.z >= from.z)
				and (current.x <= to.x and current.y <= to.y and current.z <= to.z))
		TYPE_VECTOR4, TYPE_VECTOR4I:
			return ((current.x >= from.x and current.y >= from.y and current.z >= from.z and current.w >= from.w)
				and (current.x <= to.x and current.y <= to.y and current.z <= to.z and current.w <= to.w))
		_:
			push_error("Missing implementation '_is_equal_approx' for vector type %s" % typeof(current))
			return false


func is_less(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	var current = current_value()
	if current == null or current >= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_THAN, current, expected))
	return report_success()


func is_less_equal(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	var current = current_value()
	if current == null or current > expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_EQUAL, current, expected))
	return report_success()


func is_greater(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	var current = current_value()
	if current == null or current <= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_THAN, current, expected))
	return report_success()


func is_greater_equal(expected :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(expected):
		return self
	var current = current_value()
	if current == null or current < expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_EQUAL, current, expected))
	return report_success()


func is_between(from :Variant, to :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(from) or not _validate_is_vector_type(to):
		return self
	var current = current_value()
	if current == null or not (current >= from and current <= to):
		return report_error(GdAssertMessages.error_is_value(Comparator.BETWEEN_EQUAL, current, from, to))
	return report_success()


func is_not_between(from :Variant, to :Variant) -> GdUnitVectorAssert:
	if not _validate_is_vector_type(from) or not _validate_is_vector_type(to):
		return self
	var current = current_value()
	if (current != null and current >= from and current <= to):
		return report_error(GdAssertMessages.error_is_value(Comparator.NOT_BETWEEN_EQUAL, current, from, to))
	return report_success()
