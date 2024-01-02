@tool
extends EditorDebuggerPlugin

const DebuggerTab := preload("debugger_tab.gd")
const BeehaveUtils := preload("res://addons/beehave/utils/utils.gd")

var debugger_tab := DebuggerTab.new()
var floating_window: Window
var session: EditorDebuggerSession


func _has_capture(prefix: String) -> bool:
	return prefix == "beehave"


func _capture(message: String, data: Array, session_id: int) -> bool:
	# in case the behavior tree has invalid setup this might be null
	if debugger_tab == null:
		return false
	
	if message == "beehave:register_tree":
		debugger_tab.register_tree(data[0])
		return true
	if message == "beehave:unregister_tree":
		debugger_tab.unregister_tree(data[0])
		return true
	if message == "beehave:process_tick":
		debugger_tab.graph.process_tick(data[0], data[1])
		return true
	if message == "beehave:process_begin":
		debugger_tab.graph.process_begin(data[0])
		return true
	if message == "beehave:process_end":
		debugger_tab.graph.process_end(data[0])
		return true
	return false


func _setup_session(session_id: int) -> void:
	session = get_session(session_id)
	session.started.connect(debugger_tab.start)
	session.stopped.connect(debugger_tab.stop)

	debugger_tab.name = "🐝 Beehave"
	debugger_tab.make_floating.connect(_on_make_floating)
	debugger_tab.session = session
	session.add_session_tab(debugger_tab)


func _on_make_floating() -> void:
	var plugin := BeehaveUtils.get_plugin()
	if not plugin:
		return
	if floating_window:
		_on_window_close_requested()
		return

	var border_size := Vector2(4, 4) * BeehaveUtils.get_editor_scale()
	var editor_interface: EditorInterface = plugin.get_editor_interface()
	var editor_main_screen = editor_interface.get_editor_main_screen()
	debugger_tab.get_parent().remove_child(debugger_tab)

	floating_window = Window.new()

	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", editor_interface.get_base_control().get_theme_stylebox("PanelForeground", "EditorStyles"))
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	floating_window.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_child(debugger_tab)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_right", border_size.x)
	margin.add_theme_constant_override("margin_left", border_size.x)
	margin.add_theme_constant_override("margin_top", border_size.y)
	margin.add_theme_constant_override("margin_bottom", border_size.y)
	panel.add_child(margin)

	floating_window.title = "🐝 Beehave"
	floating_window.wrap_controls = true
	floating_window.min_size = Vector2i(600, 350)
	floating_window.size = debugger_tab.size
	floating_window.position = editor_main_screen.global_position
	floating_window.transient = true
	floating_window.close_requested.connect(_on_window_close_requested)
	editor_interface.get_base_control().add_child(floating_window)


func _on_window_close_requested() -> void:
	debugger_tab.get_parent().remove_child(debugger_tab)
	session.add_session_tab(debugger_tab)
	floating_window.queue_free()
	floating_window = null
