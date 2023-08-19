class_name GodotGdErrorMonitor
extends GdUnitMonitor

var _godot_log_file :String
var _eof :int
var _report_enabled := false
var _report_force : bool


func _init(force := false):
	super("GodotGdErrorMonitor")
	_report_force = force
	_godot_log_file = GdUnitSettings.get_log_path()


func start():
	_report_enabled = _report_force or is_reporting_enabled()
	if _report_enabled:
		var file = FileAccess.open(_godot_log_file, FileAccess.READ)
		if file:
			file.seek_end(0)
			_eof = file.get_length()


func stop():
	pass


func reports() -> Array[GdUnitReport]:
	var reports_ :Array[GdUnitReport] = []
	if _report_enabled:
		reports_.assign(_collect_log_entries().map(_to_report))
	return reports_


static func _to_report(errorLog :ErrorLogEntry) -> GdUnitReport:
	var failure := "%s\n\t%s\n%s %s" % [
		GdAssertMessages._error("Godot Runtime Error !"),
		GdAssertMessages._colored_value(errorLog._details),
		GdAssertMessages._error("Error:"),
		GdAssertMessages._colored_value(errorLog._message)] 
	return GdUnitReport.new().create(GdUnitReport.ABORT, errorLog._line, failure)


func scan() -> Array[ErrorLogEntry]:
	await Engine.get_main_loop().process_frame
	return _collect_log_entries()


func _collect_log_entries() -> Array[ErrorLogEntry]:
	var file = FileAccess.open(_godot_log_file, FileAccess.READ)
	file.seek(_eof)
	var records := PackedStringArray()
	while not file.eof_reached():
		records.append(file.get_line())
	var log_entries :Array[ErrorLogEntry]= []
	for index in records.size():
		if _report_force:
			log_entries.append(ErrorLogEntry.extract_push_warning(records, index))
		if _is_report_push_errors():
			log_entries.append(ErrorLogEntry.extract_push_error(records, index))
		if _is_report_script_errors():
			log_entries.append(ErrorLogEntry.extract_error(records, index))
	return log_entries.filter(func(value): return value != null )


func is_reporting_enabled() -> bool:
	return _is_report_script_errors() or _is_report_push_errors()


func _is_report_push_errors() -> bool:
	return _report_force or GdUnitSettings.is_report_push_errors()


func _is_report_script_errors() -> bool:
	return _report_force or GdUnitSettings.is_report_script_errors()
