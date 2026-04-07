@tool
extends EditorPlugin

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

var _gd_inspector :Node
var _server_node :Node
var _gd_console :Node


func _enter_tree() -> void:
	if Engine.get_version_info().hex < 0x40100:
		prints("GdUnit4 plugin requires a minimum of Godot 4.1.x Version!")
		return
	Engine.set_meta("GdUnitEditorPlugin", self)
	GdUnitSettings.setup()
	# install the GdUnit inspector
	_gd_inspector = load("res://addons/gdUnit4/src/ui/GdUnitInspector.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _gd_inspector)
	# install the GdUnit Console
	_gd_console = load("res://addons/gdUnit4/src/ui/GdUnitConsole.tscn").instantiate()
	add_control_to_bottom_panel(_gd_console, "gdUnitConsole")
	_server_node = load("res://addons/gdUnit4/src/network/GdUnitServer.tscn").instantiate()
	add_child(_server_node)
	prints("Loading GdUnit4 Plugin success")
	if GdUnitSettings.is_update_notification_enabled():
		var update_tool :Node = load("res://addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn").instantiate()
		Engine.get_main_loop().root.call_deferred("add_child", update_tool)
	if GdUnit4CSharpApiLoader.is_mono_supported():
		prints("GdUnit4Mono Version %s loaded." % GdUnit4CSharpApiLoader.version())


func _exit_tree() -> void:
	if is_instance_valid(_gd_inspector):
		remove_control_from_docks(_gd_inspector)
		_gd_inspector.free()
	if is_instance_valid(_gd_console):
		remove_control_from_bottom_panel(_gd_console)
		_gd_console.free()
	if is_instance_valid(_server_node):
		remove_child(_server_node)
		_server_node.free()
	GdUnitTools.dispose_all()
	if Engine.has_meta("GdUnitEditorPlugin"):
		Engine.remove_meta("GdUnitEditorPlugin")
	if Engine.get_version_info().hex < 0x40100 or Engine.get_version_info().hex > 0x40101:
		prints("Unload GdUnit4 Plugin success")
