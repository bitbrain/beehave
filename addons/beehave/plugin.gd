@tool
extends EditorPlugin

const BeehaveEditorDebugger := preload("debug/debugger.gd")
var editor_debugger: BeehaveEditorDebugger
var frames: RefCounted
var _custom_types: Array[StringName] = []


func _init():
	name = "BeehavePlugin"
	add_autoload_singleton("BeehaveGlobalMetrics", "metrics/beehave_global_metrics.gd")
	add_autoload_singleton("BeehaveGlobalDebugger", "debug/global_debugger.gd")
	
	# Add project settings
	if not ProjectSettings.has_setting("beehave/debugger/start_detached"):
		ProjectSettings.set_setting("beehave/debugger/start_detached", false)
		ProjectSettings.set_initial_value("beehave/debugger/start_detached", false)
		ProjectSettings.add_property_info({
			"name": "beehave/debugger/start_detached",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "If enabled, the debugger will start in a separate window"
		})
		ProjectSettings.save()
	
	print("Beehave initialized!")


func _enter_tree() -> void:
	editor_debugger = BeehaveEditorDebugger.new()
	if Engine.get_version_info().minor >= 2:
		frames = preload("debug/new_frames.gd").new()
	else:
		frames = preload("debug/old_frames.gd").new()
	add_debugger_plugin(editor_debugger)
	_register_custom_types()


func _exit_tree() -> void:
	_unregister_custom_types()
	remove_debugger_plugin(editor_debugger)


func _register_custom_types() -> void:
	# Some users report the script-class cache randomly missing BeehaveTree,
	# which makes the editor return a null instance. Register the type manually
	# so the node is still available even if the cache is broken.
	var tree_script: Script = load("res://addons/beehave/nodes/beehave_tree.gd")
	if tree_script == null:
		push_warning("Beehave: failed to load BeehaveTree script; custom type not registered.")
		return

	var tree_icon: Texture2D = load("res://addons/beehave/icons/tree.svg")
	add_custom_type("BeehaveTree", "Node", tree_script, tree_icon)
	_custom_types.append(&"BeehaveTree")


func _unregister_custom_types() -> void:
	for type_name in _custom_types:
		remove_custom_type(type_name)
	_custom_types.clear()
