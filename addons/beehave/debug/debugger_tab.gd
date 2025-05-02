@tool
class_name BeehaveDebuggerTab
extends PanelContainer

const Utils      = preload("res://addons/beehave/utils/utils.gd")
const TREE_ICON  = preload("../icons/tree.svg")
const OldGraph   = preload("old_graph_edit.gd")
const NewGraph   = preload("new_graph_edit.gd")
const Blackboard = preload("new_node_blackboard.gd")

signal make_floating

var session: EditorDebuggerSession
var first_run = true
var active_trees = {}
var active_tree_id = -1

# UI nodes
var container: HSplitContainer
var item_list: ItemList
var graph_container: HSplitContainer
var graph
var blackboard_vbox: VBoxContainer
var message: Label

func _ready() -> void:
	_build_ui()
	_init_graph()
	stop()

	visibility_changed.connect(_on_visibility_changed)
	if visible and is_visible_in_tree():
		get_tree().create_timer(0.5).timeout.connect(_on_visibility_changed)


func _build_ui() -> void:
	# Main split fills entire panel
	container = HSplitContainer.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(container)

	# Left: behavior‐tree list
	item_list = ItemList.new()
	item_list.custom_minimum_size = Vector2(300, 0)
	item_list.item_selected.connect(_on_item_selected)
	container.add_child(item_list)

	# Right: graph + (optional) blackboard
	graph_container = HSplitContainer.new()
	graph_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(graph_container)

	# Blackboard pane: narrow, hidden until needed
	blackboard_vbox = VBoxContainer.new()
	blackboard_vbox.custom_minimum_size = Vector2(500, 0)
	blackboard_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blackboard_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	blackboard_vbox.hide()
	graph_container.add_child(blackboard_vbox)

	# "Run Project for debugging" overlay
	message = Label.new()
	message.text = "Run Project for debugging"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	message.set_anchors_preset(Control.PRESET_CENTER)
	add_child(message)


func _init_graph() -> void:
	var frames = Utils.get_frames()
	if Engine.get_version_info().minor >= 2:
		graph = NewGraph.new(frames)
	else:
		graph = OldGraph.new(frames)

	# Graph on the left, blackboard (index 1) on the right
	graph.node_selected.connect(_on_graph_node_selected)
	graph.node_deselected.connect(_on_graph_node_deselected)
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph_container.add_child(graph)
	graph_container.move_child(graph, 0)

	# "Make Floating" button
	var float_btn = Button.new()
	float_btn.name = "MakeFloatingButton"
	float_btn.flat = true
	float_btn.focus_mode = Control.FOCUS_NONE
	float_btn.icon = get_theme_icon("ExternalLink", "EditorIcons")
	float_btn.pressed.connect(func():
		emit_signal("make_floating")
	)
	graph.get_menu_container().add_child(float_btn)

	# "Toggle Panel" button
	var toggle_btn = Button.new()
	toggle_btn.name = "TogglePanelButton"
	toggle_btn.flat = true
	toggle_btn.focus_mode = Control.FOCUS_NONE
	toggle_btn.icon = get_theme_icon("Back", "EditorIcons")
	toggle_btn.pressed.connect(func():
		item_list.visible = not item_list.visible
		var icon_name = "Back" if item_list.visible else "Forward"
		toggle_btn.icon = get_theme_icon(icon_name, "EditorIcons")
	)
	graph.get_menu_container().add_child(toggle_btn)
	graph.get_menu_container().move_child(toggle_btn, 0)


func start() -> void:
	container.visible = true
	message.visible   = false

	if first_run:
		first_run = false
		for delay in [0.0, 0.1, 0.5]:
			get_tree().create_timer(delay).timeout.connect(_notify_state)
	else:
		_notify_state()
	
	# Auto-detach if enabled in project settings - check every time
	if ProjectSettings.get_setting("beehave/debugger/start_detached", false):
		emit_signal("make_floating")


func _notify_state() -> void:
	if not session or not visible or not is_visible_in_tree():
		return
	session.send_message("beehave:visibility_changed", [true])
	if active_tree_id != -1:
		session.send_message("beehave:activate_tree", [active_tree_id])


func stop() -> void:
	container.visible = false
	message.visible   = true
	active_trees.clear()
	item_list.clear()
	graph.beehave_tree = {}
	blackboard_vbox.hide()


func register_tree(data: Dictionary) -> void:
	var id_str = str(data.id)
	if not active_trees.has(id_str):
		var idx = item_list.add_item(data.name, TREE_ICON)
		item_list.set_item_tooltip(idx, data.path)
		item_list.set_item_metadata(idx, data.id)
	active_trees[id_str] = data

	if data.id.to_int() == active_tree_id:
		_notify_state()

	if item_list.get_selected_items().is_empty():
		_select_item_by_id(id_str)


func unregister_tree(instance_id: int) -> void:
	var id_str = str(instance_id)
	for i in range(item_list.get_item_count()):
		if item_list.get_item_metadata(i) == id_str:
			item_list.remove_item(i)
			break
	active_trees.erase(id_str)
	if graph.beehave_tree.get("id", "") == id_str:
		graph.beehave_tree = {}
	blackboard_vbox.hide()


func _select_item_by_id(id_str: String) -> void:
	for i in range(item_list.get_item_count()):
		if item_list.get_item_metadata(i) == id_str:
			item_list.select(i)
			break
	get_tree().create_timer(0.2).timeout.connect(func():
		if item_list.is_inside_tree() and not item_list.get_selected_items().is_empty():
			_on_item_selected(item_list.get_selected_items()[0])
	)


func _on_item_selected(idx: int) -> void:
	if idx < 0 or idx >= item_list.get_item_count():
		return

	# Immediately hide & clear the blackboard when switching trees
	blackboard_vbox.hide()
	for child in blackboard_vbox.get_children():
		child.free()

	var id = item_list.get_item_metadata(idx)
	var tree_data = active_trees.get(str(id), {})
	if tree_data.is_empty():
		return

	graph.beehave_tree = tree_data
	active_tree_id = id.to_int()
	_notify_state()
	get_tree().create_timer(0.1).timeout.connect(_notify_state)


func _on_graph_node_selected(node: GraphNode) -> void:
	blackboard_vbox.show()
	blackboard_vbox.add_child(Blackboard.new(Utils.get_frames(), node))


func _on_graph_node_deselected(node: GraphNode) -> void:
	for child in blackboard_vbox.get_children():
		if child.name == node.name:
			child.free()
	if blackboard_vbox.get_child_count() == 0:
		blackboard_vbox.hide()


func _on_visibility_changed() -> void:
	_notify_state()
