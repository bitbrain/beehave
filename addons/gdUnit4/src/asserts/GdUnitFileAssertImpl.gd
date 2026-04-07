extends GdUnitFileAssert

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

var _base: GdUnitAssert


func _init(current):
	_base = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitAssertImpl.gd", "GDScript",
								ResourceLoader.CACHE_MODE_REUSE).new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not GdUnitAssertions.validate_value_type(current, TYPE_STRING):
		report_error("GdUnitFileAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func current_value() -> String:
	return _base.current_value() as String


func report_success() -> GdUnitFileAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitFileAssert:
	_base.report_error(error)
	return self


func failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitFileAssert:
	_base.override_failure_message(message)
	return self


func is_equal(expected) -> GdUnitFileAssert:
	_base.is_equal(expected)
	return self


func is_not_equal(expected) -> GdUnitFileAssert:
	_base.is_not_equal(expected)
	return self


func is_file() -> GdUnitFileAssert:
	var current := current_value()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Is not a file '%s', error code %s" % [current, FileAccess.get_open_error()])
	return report_success()


func exists() -> GdUnitFileAssert:
	var current := current_value()
	if not FileAccess.file_exists(current):
		return report_error("The file '%s' not exists" %current)
	return report_success()


func is_script() -> GdUnitFileAssert:
	var current := current_value()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Can't acces the file '%s'! Error code %s" % [current, FileAccess.get_open_error()])

	var script = load(current)
	if not script is GDScript:
		return report_error("The file '%s' is not a GdScript" % current)
	return report_success()


func contains_exactly(expected_rows :Array) -> GdUnitFileAssert:
	var current := current_value()
	if FileAccess.open(current, FileAccess.READ) == null:
		return report_error("Can't acces the file '%s'! Error code %s" % [current, FileAccess.get_open_error()])

	var script = load(current)
	if script is GDScript:
		var instance = script.new()
		var source_code = GdScriptParser.to_unix_format(instance.get_script().source_code)
		GdUnitTools.free_instance(instance)
		var rows := Array(source_code.split("\n"))
		ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitArrayAssertImpl.gd", "GDScript",
							ResourceLoader.CACHE_MODE_REUSE).new(rows).contains_exactly(expected_rows)
	return self
