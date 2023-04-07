class_name GodotGdErrorMonitor
extends GdUnitMonitor


const USER_SCRIPT_ERROR := "USER SCRIPT ERROR:"
const USER_PUSH_ERROR := "USER ERROR:"

var _godot_log_file :String
var _eof :int
var _report_enabled := false


func _init():
	super("GodotGdErrorMonitor")
	_godot_log_file = GdUnitSettings.get_log_path().get_base_dir() + "/godot.log"


func start():
	_report_enabled = is_reporting_enabled()
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
		var loggs := _collect_log_entries()
		for index in loggs.size():
			var message := loggs[index]
			if _is_report_script_errors() and message.contains(USER_SCRIPT_ERROR):
				reports_.append(GodotGdErrorMonitor._report_runtime_error(message, loggs[index+1]))
			if _is_report_push_errors() and message.contains(USER_PUSH_ERROR):
				reports_.append(GodotGdErrorMonitor._report_user_error(message, loggs[index+1]))
	return reports_


func is_reporting_enabled() -> bool:
	return _is_report_script_errors() or _is_report_push_errors()


static func _report_runtime_error(error :String, details :String) -> GdUnitReport:
	error = error.replace(USER_SCRIPT_ERROR, "").strip_edges()
	details = details.strip_edges()
	var line := _parse_error_line_number(details)
	var failure := "%s\n\t%s\n%s %s" % [
		GdAssertMessages._error("Runtime Error !"),
		GdAssertMessages._colored_value(details),
		GdAssertMessages._error("Error:"),
		GdAssertMessages._colored_value(error)] 
	return GdUnitReport.new().create(GdUnitReport.ABORT, line, failure)


static func _report_user_error(error :String, details :String) -> GdUnitReport:
	error = error.replace(USER_PUSH_ERROR, "").strip_edges()
	details = details.strip_edges()
	var line := _parse_error_line_number(details)
	var failure := "%s\n\t%s\n%s %s" % [
		GdAssertMessages._error("User Error !"),
		GdAssertMessages._colored_value(details),
		GdAssertMessages._error("Error:"),
		GdAssertMessages._colored_value(error)] 
	return GdUnitReport.new().create(GdUnitReport.ABORT, line, failure)


func _collect_log_entries() -> PackedStringArray:
	var file = FileAccess.open(_godot_log_file, FileAccess.READ)
	file.seek(_eof)
	var current_log := PackedStringArray()
	while not file.eof_reached():
		current_log.append(file.get_line())
	return current_log


static func _parse_error_line_number(error :String) -> int:
	var matches := GdUnitTools.to_regex("at: .*res://.*:(\\d+)").search(error)
	if matches != null:
		return matches.get_string(1).to_int()
	return -1


func _is_report_push_errors() -> bool:
	return GdUnitSettings.is_report_push_errors()


func _is_report_script_errors() -> bool:
	return GdUnitSettings.is_report_script_errors()
