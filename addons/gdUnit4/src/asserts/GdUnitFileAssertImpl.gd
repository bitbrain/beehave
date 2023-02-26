class_name GdUnitFileAssertImpl
extends GdUnitFileAssert

var _base: GdUnitAssert

func _init(current, expect_result: int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if not _base.__validate_value_type(current, TYPE_STRING):
		report_error("GdUnitFileAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> String:
	return _base.__current() as String

func report_success() -> GdUnitFileAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitFileAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitFileAssert:
	_base.has_failure_message(expected)
	return self

func starts_with_failure_message(expected: String) -> GdUnitFileAssert:
	_base.starts_with_failure_message(expected)
	return self

func override_failure_message(message :String) -> GdUnitFileAssert:
	_base.override_failure_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

func is_equal(expected) -> GdUnitFileAssert:
	_base.is_equal(expected)
	return self

func is_not_equal(expected) -> GdUnitFileAssert:
	_base.is_not_equal(expected)
	return self

func is_file() -> GdUnitFileAssert:
	var current := __current()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Is not a file '%s', error code %s" % [current, FileAccess.get_open_error()])
	return report_success()

func exists() -> GdUnitFileAssert:
	var current := __current()
	if not FileAccess.file_exists(current):
		return report_error("The file '%s' not exists" %current)
	return report_success()

func is_script() -> GdUnitFileAssert:
	var current := __current()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Can't acces the file '%s'! Error code %s" % [current, FileAccess.get_open_error()])
	
	var script = load(current)
	if not script is GDScript:
		return report_error("The file '%s' is not a GdScript" % current)
	return report_success()

func contains_exactly(expected_rows :Array) -> GdUnitFileAssert:
	var current := __current()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Can't acces the file '%s'! Error code %s" % [current, FileAccess.get_open_error()])
	
	var script = load(current)
	if script is GDScript:
		var instance = script.new()
		var source_code = GdScriptParser.to_unix_format(instance.get_script().source_code)
		GdUnitTools.free_instance(instance)
		var rows := Array(source_code.split("\n"))
		GdUnitArrayAssertImpl.new(rows, GdUnitAssert.EXPECT_SUCCESS).contains_exactly(expected_rows)
	return self
