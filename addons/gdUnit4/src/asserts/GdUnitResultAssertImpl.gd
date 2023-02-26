class_name GdUnitResultAssertImpl
extends GdUnitResultAssert

var _base :GdUnitAssert

func _init(current, expect_result :int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if not __validate_value_type(current):
		report_error("GdUnitResultAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __validate_value_type(value) -> bool:
	return value is ValueProvider or value == null or value is Result

func __current() -> Result:
	return _base.__current() as Result

func report_success() -> GdUnitResultAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitResultAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitResultAssert:
	_base.has_failure_message(expected)
	return self

func starts_with_failure_message(expected: String) -> GdUnitResultAssert:
	_base.starts_with_failure_message(expected)
	return self

func override_failure_message(message :String) -> GdUnitResultAssert:
	_base.override_failure_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

# Verifies that the current value is null.
func is_null() -> GdUnitResultAssert:
	_base.is_null()
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitResultAssert:
	_base.is_not_null()
	return self

# Verifies that the result is ends up with empty
func is_empty() -> GdUnitResultAssert:
	var result := __current()
	if result == null or not result.is_empty():
		report_error(GdAssertMessages.error_result_is_empty(result))
	else:
		report_success()
	return self

# Verifies that the result is ends up with success
func is_success() -> GdUnitResultAssert:
	var result := __current()
	if result == null or not result.is_success():
		report_error(GdAssertMessages.error_result_is_success(result))
	else:
		report_success()
	return self

# Verifies that the result is ends up with warning
func is_warning() -> GdUnitResultAssert:
	var result := __current()
	if result == null or not result.is_warn():
		report_error(GdAssertMessages.error_result_is_warning(result))
	else:
		report_success()
	return self

# Verifies that the result is ends up with error
func is_error() -> GdUnitResultAssert:
	var result := __current()
	if result == null or not result.is_error():
		report_error(GdAssertMessages.error_result_is_error(result))
	else:
		report_success()
	return self

# Verifies that the result contains the expected message
func contains_message(expected :String) -> GdUnitResultAssert:
	var result := __current()
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

# Verifies that the result contains the expected value
func is_value(expected) -> GdUnitResultAssert:
	var result := __current()
	var value = null if result == null else result.value()
	if not GdObjects.equals(value, expected):
		report_error(GdAssertMessages.error_result_is_value(value, expected))
	else:
		report_success()
	return self

# Verifies that the result contains the expected value. same as #is_value
func is_equal(expected) -> GdUnitResultAssert:
	return is_value(expected)
