@tool
extends EditorPlugin

var _gd_inspector :Node
var _server_node
var _gd_console :Node


# removes GdUnit classes inherits from Godot.Node from the node inspecor, ohterwise it takes very long to popup the dialog
func _fixup_node_inspector() -> void:
	var classes := PackedStringArray([
		"GdUnitTestSuite",
		"_TestCase",
		"GdUnitInspecor",
		"GdUnitExecutor",
		"GdUnitTcpClient",
		"GdUnitTcpServer"])
	for clazz in classes:
		remove_custom_type(clazz)


func _enter_tree():
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
	_fixup_node_inspector()
	prints("Loading GdUnit4 Plugin success")


func _exit_tree():
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
	prints("Unload GdUnit4 Plugin success")
