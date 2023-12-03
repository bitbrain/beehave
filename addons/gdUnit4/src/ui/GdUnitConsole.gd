@tool
extends Control

const TITLE = "gdUnit4 ${version} Console"

@onready var header := $VBoxContainer/Header
@onready var title :RichTextLabel = $VBoxContainer/Header/header_title
@onready var output :RichTextLabel = $VBoxContainer/Console/TextEdit

var _text_color :Color
var _function_color :Color
var _engine_type_color :Color
var _statistics = {}
var _summary = {
	"total_count": 0,
	"error_count": 0,
	"failed_count": 0,
	"skipped_count": 0,
	"orphan_nodes": 0
}


func _ready():
	init_colors()
	GdUnitFonts.init_fonts(output)
	GdUnit4Version.init_version_label(title)
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	GdUnitSignals.instance().gdunit_message.connect(_on_gdunit_message)
	GdUnitSignals.instance().gdunit_client_connected.connect(_on_gdunit_client_connected)
	GdUnitSignals.instance().gdunit_client_disconnected.connect(_on_gdunit_client_disconnected)
	output.clear()


func _notification(what):
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		init_colors()
	if what == NOTIFICATION_PREDELETE:
		GdUnitSignals.instance().gdunit_event.disconnect(_on_gdunit_event)
		GdUnitSignals.instance().gdunit_message.disconnect(_on_gdunit_message)
		GdUnitSignals.instance().gdunit_client_connected.disconnect(_on_gdunit_client_connected)
		GdUnitSignals.instance().gdunit_client_disconnected.disconnect(_on_gdunit_client_disconnected)


func init_colors() -> void:
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var settings := plugin.get_editor_interface().get_editor_settings()
	_text_color = settings.get_setting("text_editor/theme/highlighting/text_color")
	_function_color = settings.get_setting("text_editor/theme/highlighting/function_color")
	_engine_type_color = settings.get_setting("text_editor/theme/highlighting/engine_type_color")


func init_statistics(event :GdUnitEvent) :
	_statistics["total_count"] = event.total_count()
	_statistics["error_count"] = 0
	_statistics["failed_count"] = 0
	_statistics["skipped_count"] = 0
	_statistics["orphan_nodes"] = 0
	_summary["total_count"] += event.total_count()


func reset_statistics() -> void:
	for k in _statistics.keys():
		_statistics[k] = 0
	for k in _summary.keys():
		_summary[k] = 0


func update_statistics(event :GdUnitEvent) :
	_statistics["error_count"] += event.error_count()
	_statistics["failed_count"] += event.failed_count()
	_statistics["skipped_count"] += event.skipped_count()
	_statistics["orphan_nodes"] += event.orphan_nodes()
	_summary["error_count"] += event.error_count()
	_summary["failed_count"] += event.failed_count()
	_summary["skipped_count"] += event.skipped_count()
	_summary["orphan_nodes"] += event.orphan_nodes()


func print_message(message :String, color :Color = _text_color, indent :int = 0) -> void:
	for i in indent:
		output.push_indent(1)
	output.push_color(color)
	output.append_text(message)
	output.pop()
	for i in indent:
		output.pop()


func println_message(message :String, color :Color = _text_color, indent :int = -1) -> void:
	print_message(message, color, indent)
	output.newline()


func _on_gdunit_event(event :GdUnitEvent):
	match event.type():
		GdUnitEvent.INIT:
			reset_statistics()
		
		GdUnitEvent.STOP:
			print_message("Summary:", Color.DODGER_BLUE)
			println_message("| %d total | %d error | %d failed | %d skipped | %d orphans |" % [_summary["total_count"], _summary["error_count"], _summary["failed_count"], _summary["skipped_count"], _summary["orphan_nodes"]], _text_color, 1)
			print_message("[wave][/wave]")
		
		GdUnitEvent.TESTSUITE_BEFORE:
			init_statistics(event)
			print_message("Execute: ", Color.DODGER_BLUE)
			println_message(event._suite_name, _engine_type_color)
		
		GdUnitEvent.TESTSUITE_AFTER:
			update_statistics(event)
			if not event.reports().is_empty():
				var report :GdUnitReport = event.reports().front()
				println_message("\t" +event._suite_name, _engine_type_color)
				println_message("line %d %s" % [report._line_number, report._message], _text_color, 2)
			if event.is_success():
				print_message("[wave]PASSED[/wave]", Color.LIGHT_GREEN)
			else:
				print_message("[shake rate=5 level=10][b]FAILED[/b][/shake]", Color.FIREBRICK)
			print_message(" | %d total | %d error | %d failed | %d skipped | %d orphans |" % [_statistics["total_count"], _statistics["error_count"], _statistics["failed_count"], _statistics["skipped_count"], _statistics["orphan_nodes"]])
			println_message("%+12s" % LocalTime.elapsed(event.elapsed_time()))
			println_message(" ")
		
		GdUnitEvent.TESTCASE_BEFORE:
			var spaces = "-%d" % (80 - event._suite_name.length())
			print_message(event._suite_name, _engine_type_color, 1)
			print_message(":")
			print_message(("%"+spaces+"s") % event._test_name, _function_color)
		
		GdUnitEvent.TESTCASE_AFTER:
			var reports := event.reports()
			update_statistics(event)
			if event.is_success():
				print_message("PASSED", Color.LIGHT_GREEN)
			elif event.is_skipped():
				print_message("SKIPPED", Color.GOLDENROD)
			elif event.is_error() or event.is_failed():
				print_message("[wave]FAILED[/wave]", Color.FIREBRICK)
			elif event.is_warning():
				print_message("WARNING", Color.YELLOW)
			println_message(" %+12s" % LocalTime.elapsed(event.elapsed_time()))
			
			var report :GdUnitReport = null if reports.is_empty() else reports[0]
			if report:
				println_message("line %d %s" % [report._line_number, report._message], _text_color, 2)


func _on_gdunit_client_connected(client_id :int) -> void:
	output.clear()
	output.append_text("[color=#9887c4]GdUnit Test Client connected with id %d[/color]\n" % client_id)
	output.newline()


func _on_gdunit_client_disconnected(client_id :int) -> void:
	output.append_text("[color=#9887c4]GdUnit Test Client disconnected with id %d[/color]\n" % client_id)
	output.newline()


func _on_gdunit_message(message :String):
	output.newline()
	output.append_text(message)
	output.newline()
