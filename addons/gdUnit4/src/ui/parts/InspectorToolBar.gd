@tool
extends HBoxContainer

signal run_overall_pressed(debug :bool)
signal run_pressed(debug :bool)
signal stop_pressed()

@onready var debug_icon_image :Texture2D = load("res://addons/gdUnit4/src/ui/assets/PlayDebug.svg")
@onready var overall_icon_image :Texture2D = load("res://addons/gdUnit4/src/ui/assets/PlayOverall.svg")
@onready var _version_label := %version
@onready var _button_wiki := %help
@onready var _tool_button := %tool
@onready var _button_run_overall :Button = %"run-overall"
@onready var _button_run := %run
@onready var _button_run_debug := %debug
@onready var _button_stop := %stop


const SETTINGS_SHORTCUT_MAPPING := {
	GdUnitSettings.SHORTCUT_INSPECTOR_RERUN_TEST : GdUnitShortcut.ShortCut.RERUN_TESTS,
	GdUnitSettings.SHORTCUT_INSPECTOR_RERUN_TEST_DEBUG : GdUnitShortcut.ShortCut.RERUN_TESTS_DEBUG,
	GdUnitSettings.SHORTCUT_INSPECTOR_RUN_TEST_OVERALL : GdUnitShortcut.ShortCut.RUN_TESTS_OVERALL,
	GdUnitSettings.SHORTCUT_INSPECTOR_RUN_TEST_STOP : GdUnitShortcut.ShortCut.STOP_TEST_RUN,
}


func _ready():
	GdUnit4Version.init_version_label(_version_label)
	var command_handler := GdUnitCommandHandler.instance()
	run_pressed.connect(command_handler._on_run_pressed)
	run_overall_pressed.connect(command_handler._on_run_overall_pressed)
	stop_pressed.connect(command_handler._on_stop_pressed)
	command_handler.gdunit_runner_start.connect(_on_gdunit_runner_start)
	command_handler.gdunit_runner_stop.connect(_on_gdunit_runner_stop)
	GdUnitSignals.instance().gdunit_settings_changed.connect(_on_gdunit_settings_changed)
	init_buttons()
	init_shortcuts(command_handler)


func init_buttons() -> void:
	var editor :EditorPlugin = EditorPlugin.new()
	var editior_control := editor.get_editor_interface().get_base_control()
	_button_run_overall.icon = overall_icon_image
	_button_run_overall.visible = GdUnitSettings.is_inspector_toolbar_button_show()
	_button_run.icon = GodotVersionFixures.get_icon(editior_control, "Play")
	_button_run_debug.icon = debug_icon_image
	_button_stop.icon = GodotVersionFixures.get_icon(editior_control, "Stop")
	_tool_button.icon = GodotVersionFixures.get_icon(editior_control, "Tools")
	_button_wiki.icon = GodotVersionFixures.get_icon(editior_control, "HelpSearch")


func init_shortcuts(command_handler :GdUnitCommandHandler) -> void:
	_button_run.shortcut = command_handler.get_shortcut(GdUnitShortcut.ShortCut.RERUN_TESTS)
	_button_run_overall.shortcut = command_handler.get_shortcut(GdUnitShortcut.ShortCut.RUN_TESTS_OVERALL)
	_button_run_debug.shortcut = command_handler.get_shortcut(GdUnitShortcut.ShortCut.RERUN_TESTS_DEBUG)
	_button_stop.shortcut = command_handler.get_shortcut(GdUnitShortcut.ShortCut.STOP_TEST_RUN)
	# register for shortcut changes
	GdUnitSignals.instance().gdunit_settings_changed.connect(_on_settings_changed.bind(command_handler))


func _on_runoverall_pressed(debug := false):
	run_overall_pressed.emit(debug)


func _on_run_pressed(debug := false):
	run_pressed.emit(debug)


func _on_stop_pressed():
	stop_pressed.emit()


func _on_gdunit_runner_start():
	_button_run_overall.disabled = true
	_button_run.disabled = true
	_button_run_debug.disabled = true
	_button_stop.disabled = false


func _on_gdunit_runner_stop(_client_id :int):
	_button_run_overall.disabled = false
	_button_run.disabled = false
	_button_run_debug.disabled = false
	_button_stop.disabled = true


func _on_gdunit_settings_changed(_property :GdUnitProperty):
	_button_run_overall.visible = GdUnitSettings.is_inspector_toolbar_button_show()


func _on_wiki_pressed():
	OS.shell_open("https://mikeschulze.github.io/gdUnit4/")


func _on_btn_tool_pressed():
	var tool_popup = load("res://addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn").instantiate()
	get_parent_control().add_child(tool_popup)


func _on_settings_changed(property :GdUnitProperty, command_handler :GdUnitCommandHandler):
	# needs to wait a frame to be command handler notified first for settings changes
	await get_tree().process_frame
	if SETTINGS_SHORTCUT_MAPPING.has(property.name()):
		var shortcut :GdUnitShortcut.ShortCut = SETTINGS_SHORTCUT_MAPPING.get(property.name(), GdUnitShortcut.ShortCut.NONE)
		match shortcut:
			GdUnitShortcut.ShortCut.RERUN_TESTS:
				_button_run.shortcut = command_handler.get_shortcut(shortcut)
			GdUnitShortcut.ShortCut.RUN_TESTS_OVERALL:
				_button_run_overall.shortcut = command_handler.get_shortcut(shortcut)
			GdUnitShortcut.ShortCut.RERUN_TESTS_DEBUG:
				_button_run_debug.shortcut = command_handler.get_shortcut(shortcut)
			GdUnitShortcut.ShortCut.STOP_TEST_RUN:
				_button_stop.shortcut = command_handler.get_shortcut(shortcut)
