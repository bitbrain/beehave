#!/usr/bin/env -S godot -s
extends SceneTree

enum {
	INIT,
	PROCESSING,
	EXIT
}

const RETURN_SUCCESS  =   0
const RETURN_ERROR    = 100
const RETURN_WARNING  = 101

var _console := CmdConsole.new()
var _cmd_options: = CmdOptions.new([
	CmdOption.new(
		"-scp, --src_class_path",
		"-scp <source_path>",
		"The full class path of the source file.",
		TYPE_STRING
	),
	CmdOption.new(
		"-scl, --src_class_line",
		"-scl <line_number>",
		"The selected line number to generate test case.",
		TYPE_INT
	)
])

var _status := INIT
var _source_file :String = ""
var _source_line :int = -1


func _init():
	var cmd_parser := CmdArgumentParser.new(_cmd_options, "GdUnitBuildTool.gd")
	var result := cmd_parser.parse(OS.get_cmdline_args())
	if result.is_error():
		show_options()
		exit(RETURN_ERROR, result.error_message());
		return
	var cmd_options = result.value()
	for cmd in cmd_options:
		if cmd.name() == '-scp':
			_source_file = cmd.arguments()[0]
			_source_file = ProjectSettings.localize_path(ProjectSettings.localize_path(_source_file))
		if cmd.name() == '-scl':
			_source_line = int(cmd.arguments()[0])
	# verify required arguments
	if _source_file == "":
		exit(RETURN_ERROR, "missing required argument -scp <source>")
		return
	if _source_line == -1:
		exit(RETURN_ERROR, "missing required argument -scl <number>")
		return
	_status = PROCESSING


func _idle(_delta):
	if _status == PROCESSING:
		var script := ResourceLoader.load(_source_file) as Script
		if script == null:
			exit(RETURN_ERROR, "Can't load source file %s!" % _source_file)
		var result := GdUnitTestSuiteBuilder.create(script, _source_line)
		if result.is_error():
			print_json_error(result.error_message())
			exit(RETURN_ERROR, result.error_message())
			return
		_console.prints_color("Added testcase: %s" % result.value(), Color.CORNFLOWER_BLUE)
		print_json_result(result.value())
		exit(RETURN_SUCCESS)


func exit(code :int, message :String = "") -> void:
	_status = EXIT
	if code == RETURN_ERROR:
		if not message.is_empty():
			_console.prints_error(message)
		_console.prints_error("Abnormal exit with %d" % code)
	else:
		_console.prints_color("Exit code: %d" % RETURN_SUCCESS, Color.DARK_SALMON)
	quit(code)


func print_json_result(result :Dictionary) -> void:
	# convert back to system path
	var path = ProjectSettings.globalize_path(result["path"]);
	var json = 'JSON_RESULT:{"TestCases" : [{"line":%d, "path": "%s"}]}' % [result["line"], path]
	prints(json)


func print_json_error(error :String) -> void:
	prints('JSON_RESULT:{"Error" : "%s"}' % error)


func show_options() -> void:
	_console.prints_color(" Usage:", Color.DARK_SALMON)
	_console.prints_color("	build -scp <source_path> -scl <line_number>", Color.DARK_SALMON)
	_console.prints_color("-- Options ---------------------------------------------------------------------------------------",
		Color.DARK_SALMON).new_line()
	for option in _cmd_options.default_options():
		descripe_option(option)


func descripe_option(cmd_option :CmdOption) -> void:
	_console.print_color("  %-40s" % str(cmd_option.commands()), Color.CORNFLOWER_BLUE)
	_console.prints_color(cmd_option.description(), Color.LIGHT_GREEN)
	if not cmd_option.help().is_empty():
		_console.prints_color("%-4s %s" % ["", cmd_option.help()], Color.DARK_TURQUOISE)
	_console.new_line()
