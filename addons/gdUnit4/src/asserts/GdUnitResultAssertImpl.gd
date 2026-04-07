extends GdUnitResultAssert

var _base :GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not validate_value_type(current):
		report_error("GdUnitResultAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func validate_value_type(value) -> bool:
	return value == null or value is GdUnitResult


func current_value() -> GdUnitResult:
	return _base.current_value() as GdUnitResult


func report_success() -> GdUnitResultAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitResultAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitResultAssert:
	_base.override_failure_message(message)
	return self


func is_null() -> GdUnitResultAssert:
	_base.is_null()
	return self

func is_not_null() -> GdUnitResultAssert:
	_base.is_not_null()
	return self


func is_empty() -> GdUnitResultAssert:
	var result := current_value()
	if result == null or not result.is_empty():
		report_error(GdAssertMessages.error_result_is_empty(result))
	else:
		report_success()
	return self


func is_success() -> GdUnitResultAssert:
	var result := current_value()
	if result == null or not result.is_success():
		report_error(GdAssertMessages.error_result_is_success(result))
	else:
		report_success()
	return self


func is_warning() -> GdUnitResultAssert:
	var result := current_value()
	if result == null or not result.is_warn():
		report_error(GdAssertMessages.error_result_is_warning(result))
	else:
		report_success()
	return self


func is_error() -> GdUnitResultAssert:
	var result := current_value()
	if result == null or not result.is_error():
		report_error(GdAssertMessages.error_result_is_error(result))
	else:
		report_success()
	return self


func contains_message(expected :String) -> GdUnitResultAssert:
	var result := current_value()
	if result == null:
		report_error(GdAssertMessages.error_result_has_message("<null>", expected))
		return self
	if result.is_success():
		report_error(GdAssertMessages.error_result_has_message_on_success(expected))
	elif result.is_error() and result.error_message() != expected:
		report_error(GdAssertMessages.error_result_has_message(result.error_message(), expected))
	elif result.is_warn() and result.warn_message() != expected:
		report_error(GdAssertMessages.error_result_has_message(result.warn_message(), expected))
	else:
		report_success()
	return self


func is_value(expected) -> GdUnitResultAssert:
	var result := current_value()
	var value = null if result == null else result.value()
	if not GdObjects.equals(value, expected):
		report_error(GdAssertMessages.error_result_is_value(value, expected))
	else:
		report_success()
	return self


func is_equal(expected) -> GdUnitResultAssert:
	return is_value(expected)
