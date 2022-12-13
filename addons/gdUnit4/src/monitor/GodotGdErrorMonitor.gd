class_name GodotGdErrorMonitor
extends GdUnitMonitor

var _godot_log_file :String
var _eof :int
var _report_enabled := false

func _init():
	super("GodotGdErrorMonitor")
	_godot_log_file = GdUnitSettings.get_log_path().get_base_dir() + "/godot.log"
	_report_enabled = is_reporting_enabled()

func start():
	if _report_enabled:
		var file = FileAccess.open(_godot_log_file, FileAccess.READ)
		file.seek_end(0)
		_eof = file.get_length()

func stop():
	pass

func reports() -> Array:
	if _report_enabled:
		return _scan_for_errors()
	return []

func is_reporting_enabled() -> bool:
	return _is_report_script_errors() or _is_report_push_errors()

func _collect_seek_log() -> String:
	var file = FileAccess.open(_godot_log_file, FileAccess.READ)
	file.seek(_eof)
	var current_log := ""
	var line := file.get_line()
	while line != null and not file.eof_reached():
		current_log += line + "\n"
		line = file.get_line()
	return current_log

func _scan_for_errors() -> Array:
	var _reports :Array = Array()
	var loggs := _collect_seek_log().split("\n")
	for index in loggs.size():
		var message := loggs[index] as String
		if _is_report_script_errors() and message.find("**SCRIPT ERROR**:") != -1:
			var error = message + "\n" + loggs[index+1]
			var line := _parse_error_line_number(error)
			_reports.append(GdUnitReport.new().create(GdUnitReport.FAILURE, line, error))
		if _is_report_push_errors() and message.find("**ERROR**:") != -1:
			var error = message + "\n" + loggs[index+1]
			_reports.append(GdUnitReport.new().create(GdUnitReport.FAILURE, -1, error))
	return _reports

func _parse_error_line_number(error :String) -> int:
	var _regex := RegEx.new()
	_regex.compile("(At: res:\\/\\/.*\\:(\\d+):)")
	var matches := _regex.search_all(error)
	if matches != null and matches.size() > 0:
		return matches[0].get_string(2).to_int()
	return -1

func _is_report_push_errors() -> bool:
	return GdUnitSettings.is_report_push_errors()
	
func _is_report_script_errors() -> bool:
	return GdUnitSettings.is_report_script_errors()
