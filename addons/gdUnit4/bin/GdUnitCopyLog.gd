#!/usr/bin/env -S godot -s
extends MainLoop

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

const NO_LOG_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<meta http-equiv="x-ua-compatible" content="IE=edge"/>
	<title>Logging</title>
	<link href="css/style.css" rel="stylesheet" type="text/css"/>
</head>
<body>
	<div>
		<h1>No logging available!</h1>
		</br>
		<p>For logging to occur, you must check Enable File Logging in Project Settings.</p>
		<p>You can enable Logging <b>Project Settings</b> > <b>Logging</b> > <b>File Logging</b> > <b>Enable File Logging</b> in the Project Settings.</p>
	</div>
</body>
"""

#warning-ignore-all:return_value_discarded
var _cmd_options: = CmdOptions.new([
			CmdOption.new("-rd, --report-directory", "-rd <directory>", "Specifies the output directory in which the reports are to be written. The default is res://reports/.", TYPE_STRING, true),
])

var _report_root_path :String

func _init():
	_report_root_path = GdUnitTools.current_dir() + "reports"

func _process(_delta):
	# check if reports exists
	if not reports_available():
		prints("no reports found")
		return true
	# scan for latest report path
	var iteration = GdUnitTools.find_last_path_index(_report_root_path, GdUnitHtmlReport.REPORT_DIR_PREFIX)
	var report_path = "%s/%s%d" % [_report_root_path, GdUnitHtmlReport.REPORT_DIR_PREFIX, iteration]
	
	# only process if godot logging is enabled
	if not GdUnitSettings.is_log_enabled():
		_patch_report(report_path, "")
		return true
	
	# parse possible custom report path, 
	var cmd_parser := CmdArgumentParser.new(_cmd_options, "GdUnitCmdTool.gd")
	# ignore erros and exit quitly
	if cmd_parser.parse(OS.get_cmdline_args(), true).is_error():
		return true
	CmdCommandHandler.new(_cmd_options).register_cb("-rd", Callable(self, "set_report_directory"))
	
	# scan for latest godot log and copy to report
	var godot_log := _scan_latest_godot_log()
	var result := _copy_and_pach(godot_log, report_path)
	if result.is_error():
		push_error(result.error_message())
		return true
	
	_patch_report(report_path, godot_log)
	return true

func set_report_directory(path :String) -> void:
	_report_root_path = path

func _scan_latest_godot_log() -> String:
	var path := GdUnitSettings.get_log_path().get_base_dir()
	var files_sorted := Array()
	for file in GdUnitTools.scan_dir(path):
		var file_name := "%s/%s" % [path,file]
		files_sorted.append(file_name)
	# sort by name, the name contains the timestamp so we sort at the end by timestamp
	files_sorted.sort()
	return files_sorted[-1]

func _patch_report(report_path :String, godot_log :String) -> void:
	var index_file := FileAccess.open("%s/index.html" % report_path, FileAccess.READ_WRITE)
	if index_file == null:
		push_error("Can't add log path to index.html. Error: %s" % GdUnitTools.error_as_string(FileAccess.get_open_error()))
		return
	# if no log file available than add a information howto enable it
	if godot_log.is_empty():
		FileAccess.open("%s/logging_not_available.html" % report_path, FileAccess.WRITE)\
			.store_string(NO_LOG_TEMPLATE)
	var log_file = "logging_not_available.html" if godot_log.is_empty() else godot_log.get_file()
	var content := index_file.get_as_text().replace("${log_file}", log_file)
	# overide it
	index_file.seek(0)
	index_file.store_string(content)
	
func _copy_and_pach(from_file: String, to_dir: String) -> Result:
	var result := GdUnitTools.copy_file(from_file, to_dir)
	if result.is_error():
		return result
	var file := FileAccess.open(from_file, FileAccess.READ)
	if file == null:
		return Result.error("Can't find file '%s'. Error: %s" % [from_file, GdUnitTools.error_as_string(FileAccess.get_open_error())])
	var content := file.get_as_text()
	# patch out console format codes
	for color_index in range(0, 256):
		var to_replace := "[38;5;%dm" % color_index
		content = content.replace(to_replace, "")
	content = content.replace("[0m", "")\
		.replace(CmdConsole.__CSI_BOLD, "")\
		.replace(CmdConsole.__CSI_ITALIC, "")\
		.replace(CmdConsole.__CSI_UNDERLINE, "")
	var to_file := to_dir + "/" + from_file.get_file()
	file = FileAccess.open(to_file, FileAccess.WRITE)
	if file == null:
		return Result.error("Can't open to write '%s'. Error: %s" % [to_file, GdUnitTools.error_as_string(FileAccess.get_open_error())])
	file.store_string(content)
	return Result.empty()

func reports_available() -> bool:
	return DirAccess.dir_exists_absolute(_report_root_path)
