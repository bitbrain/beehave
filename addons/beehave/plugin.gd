@tool
extends EditorPlugin

const BeehaveEditorDebugger := preload("debug/debugger.gd")
var editor_debugger: BeehaveEditorDebugger
var frames: RefCounted

func _init():
	name = "BeehavePlugin"
	add_autoload_singleton("BeehaveGlobalMetrics", "metrics/beehave_global_metrics.gd")
	add_autoload_singleton("BeehaveGlobalDebugger", "debug/global_debugger.gd")
	print("Beehave initialized!")

func _enter_tree() -> void:
	editor_debugger = BeehaveEditorDebugger.new()
	frames = preload("debug/frames.gd").new()
	add_debugger_plugin(editor_debugger)


func _exit_tree() -> void:
	remove_debugger_plugin(editor_debugger)
