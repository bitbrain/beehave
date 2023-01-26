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
	GdUnit4Version.init_version_label(title)
	GdUnitSignals.instance().gdunit_event.connect(Callable(self, "_on_gdunit_event"))
	GdUnitSignals.instance().gdunit_message.connect(Callable(self, "_on_gdunit_message"))
	GdUnitSignals.instance().gdunit_client_connected.connect(Callable(self, "_on_gdunit_client_connected"))
	GdUnitSignals.instance().gdunit_client_disconnected.connect(Callable(self, "_on_gdunit_client_disconnected"))
	output.clear()

func _notification(what):
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		init_colors()

func init_colors() -> void:
	var plugin := EditorPlugin.new()
	var settings := plugin.get_editor_interface().get_editor_settings()
	_text_color = settings.get_setting("text_editor/theme/highlighting/text_color")
	_function_color = settings.get_setting("text_editor/theme/highlighting/function_color")
	_engine_type_color = settings.get_setting("text_editor/theme/highlighting/engine_type_color")
	plugin.free()

func init_statistics(event :GdUnitEvent) :
	_statistics["total_count"] = event.total_count()
	_statistics["error_count"] = 0
	_statistics["failed_count"] = 0
	_statistics["skipped_count"] = 0
	_statistics["orphan_nodes"] = 0
	_summary["total_count"] += event.total_count()

func update_statistics(event :GdUnitEvent) :
	_statistics["error_count"] += event.error_count()
	_statistics["failed_count"] += event.failed_count()
	_statistics["skipped_count"] += event.skipped_count()
	_statistics["orphan_nodes"] += event.orphan_nodes()
	_summary["error_count"] += event.error_count()
	_summary["failed_count"] += event.failed_count()
	_summary["skipped_count"] += event.skipped_count()
	_summary["orphan_nodes"] += event.orphan_nodes()

func _on_gdunit_event(event :GdUnitEvent):
	match event.type():
		GdUnitEvent.INIT:
			_summary["total_count"] = 0
		GdUnitEvent.STOP:
			output.newline()
			output.push_color(Color.LIGHT_GREEN.to_html())
			output.append_text("Test Run Summary:")
			output.push_color(_text_color.to_html())
			output.push_indent(1)
			output.append_text("| %d total | %d error | %d failed | %d skipped | %d orphans |\n" % [_summary["total_count"], _summary["error_count"], _summary["failed_count"], _summary["skipped_count"], _summary["orphan_nodes"]])
			output.pop()
		GdUnitEvent.TESTSUITE_BEFORE:
			init_statistics(event)
			output.append_text("Run Test Suite: %s" %  event._suite_name)
			output.newline()
		GdUnitEvent.TESTSUITE_AFTER:
			if event.is_success():
				output.push_color(Color.LIGHT_GREEN.to_html())
				output.append_text("[wave]PASSED[/wave]")
			else:
				output.push_color(Color.FIREBRICK.to_html())
				output.append_text("[shake rate=5 level=10][b]FAILED[/b][/shake]")
			output.pop()
			output.append_text(" %+12s" % LocalTime.elapsed(event.elapsed_time()))
			output.newline()
			output.push_color(_text_color.to_html())
			output.push_indent(1)
			output.append_text("| %d total | %d error | %d failed | %d skipped | %d orphans |\n" % [_statistics["total_count"], _statistics["error_count"], _statistics["failed_count"], _statistics["skipped_count"], _statistics["orphan_nodes"]])
			output.pop()
			output.pop()
			output.newline()
		GdUnitEvent.TESTCASE_BEFORE:
			var spaces = "-%d" % (80 - event._suite_name.length())
			output.push_indent(1)
			output.append_text(("[color=#" + _engine_type_color.to_html() + "]%s[/color]:[color=#" + _function_color.to_html() + "]%"+spaces+"s[/color]") % [event._suite_name, event._test_name])
			output.pop()
		GdUnitEvent.TESTCASE_AFTER:
			var reports := event.reports()
			update_statistics(event)
			if not output.text.ends_with("\n"):
				if event.is_success():
					output.push_color(Color.LIGHT_GREEN.to_html())
					output.append_text("PASSED")
					output.pop()
					output.append_text(" %+12s" % LocalTime.elapsed(event.elapsed_time()))
				else:
					if event.is_skipped():
						output.push_color(Color.GOLDENROD.to_html())
						output.append_text("SKIPPED")
					if event.is_error() or event.is_failed():
						output.push_color(Color.FIREBRICK.to_html())
						output.append_text("FAILED")
					output.pop()
					output.append_text(" %+12s" % LocalTime.elapsed(event.elapsed_time()))
					output.newline()
					output.push_color(_text_color.to_html())
					var report :GdUnitReport = null if reports.is_empty() else reports[0]
					if report:
						output.push_indent(2)
						output.append_text("line %d %s" % [report._line_number, report._message])
						output.pop()
					output.pop()
				output.newline()

func _on_gdunit_client_connected(client_id :int) -> void:
	output.clear()
	output.newline()
	output.append_text("[color=#9887c4]GdUnit Test Client connected with id %d[/color]" % client_id)

func _on_gdunit_client_disconnected(client_id :int) -> void:
	output.newline()
	output.append_text("[color=#9887c4]GdUnit Test Client disconnected with id %d[/color]" % client_id)
	output.append_text("[wave][/wave]")

func _on_gdunit_message(message :String):
	output.newline()
	output.append_text(message)
	output.newline()
