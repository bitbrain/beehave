@tool
extends EditorPlugin

const BeehaveEditorDebugger := preload("debug/debugger.gd")
var editor_debugger: BeehaveEditorDebugger
var frames: RefCounted


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
			"hint_string": "If enabled, the debugger will start in a separate window",
			"usage": PROPERTY_USAGE_DEFAULT
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


func _exit_tree() -> void:
	remove_debugger_plugin(editor_debugger)
