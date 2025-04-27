@tool
class_name BeehaveDebuggerTab extends PanelContainer

const BeehaveUtils := preload("res://addons/beehave/utils/utils.gd")

signal make_floating

const OldBeehaveGraphEdit := preload("old_graph_edit.gd")
const NewBeehaveGraphEdit := preload("new_graph_edit.gd")
const NewNodeBlackBoard := preload("new_node_blackboard.gd")

const TREE_ICON := preload("../icons/tree.svg")

var graph
var container: HSplitContainer
var graph_container: HSplitContainer
var item_list: ItemList
var blackboard_vbox: VBoxContainer
var message: Label

var active_trees: Dictionary
var active_tree_id: int = -1
var session: EditorDebuggerSession
var first_run: bool = true  # Track if this is the first run since Godot started


func _ready() -> void:
	container = HSplitContainer.new()
	add_child(container)

	item_list = ItemList.new()
	item_list.custom_minimum_size = Vector2(200, 0)
	item_list.item_selected.connect(_on_item_selected)
	container.add_child(item_list)

	graph_container = HSplitContainer.new()
	graph_container.split_offset = 1920
	graph_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(graph_container)

	if Engine.get_version_info().minor >= 2:
		graph = NewBeehaveGraphEdit.new(BeehaveUtils.get_frames())
	else:
		graph = OldBeehaveGraphEdit.new(BeehaveUtils.get_frames())

	graph.node_selected.connect(_on_graph_node_selected)
	graph.node_deselected.connect(_on_graph_node_deselected)
	graph_container.add_child(graph)

	blackboard_vbox = VBoxContainer.new()
	blackboard_vbox.custom_minimum_size = Vector2(200, 0)
	blackboard_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	graph_container.add_child(blackboard_vbox)

	message = Label.new()
	message.text = "Run Project for debugging"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.set_anchors_preset(Control.PRESET_CENTER)
	add_child(message)

	var button := Button.new()
	button.flat = true
	button.name = "MakeFloatingButton"
	button.icon = get_theme_icon(&"ExternalLink", &"EditorIcons")
	button.pressed.connect(func(): make_floating.emit())
	button.tooltip_text = "Make floating"
	button.focus_mode = Control.FOCUS_NONE
	graph.get_menu_container().add_child(button)

	var toggle_button := Button.new()
	toggle_button.flat = true
	toggle_button.name = "TogglePanelButton"
	toggle_button.icon = get_theme_icon(&"Back", &"EditorIcons")
	toggle_button.pressed.connect(_on_toggle_button_pressed.bind(toggle_button))
	toggle_button.tooltip_text = "Toggle Panel"
	toggle_button.focus_mode = Control.FOCUS_NONE
	graph.get_menu_container().add_child(toggle_button)
	graph.get_menu_container().move_child(toggle_button, 0)
	
	stop()

	visibility_changed.connect(_on_visibility_changed)
	
	# Report initial visibility after a short delay to ensure proper initialization
	if visible and is_visible_in_tree():
		get_tree().create_timer(0.5).timeout.connect(func(): _on_visibility_changed())


func start() -> void:
	container.visible = true
	message.visible = false
	
	# If this is the first run since Godot started, use a more aggressive approach
	if first_run:
		first_run = false
		
		# First-stage initialization - immediately report visibility
		if session != null and visible and is_visible_in_tree():
			session.send_message("beehave:visibility_changed", [true])
			
		# Second-stage initialization - run after a short delay to ensure UI is ready
		get_tree().create_timer(0.1).timeout.connect(func():
			if session != null and visible and is_visible_in_tree():
				session.send_message("beehave:visibility_changed", [true])
				
				# If a tree is already selected, activate it
				if active_tree_id != -1:
					session.send_message("beehave:activate_tree", [active_tree_id])
		)
		
		# Third-stage initialization - run after a longer delay as a fallback
		get_tree().create_timer(0.5).timeout.connect(func():
			if session != null and visible and is_visible_in_tree():
				session.send_message("beehave:visibility_changed", [true])
				
				# Reactivate tree and force reselection if there's something in the list
				if active_tree_id != -1:
					session.send_message("beehave:activate_tree", [active_tree_id])
				elif not item_list.get_selected_items().is_empty():
					# Force reselection of the current item
					_on_item_selected(item_list.get_selected_items()[0])
		)
	else:
		# For subsequent runs, the standard initialization is sufficient
		if session != null and visible and is_visible_in_tree():
			session.send_message("beehave:visibility_changed", [true])
			
			# If there's already an active tree, reactivate it
			if active_tree_id != -1:
				session.send_message("beehave:activate_tree", [active_tree_id])


func stop() -> void:
	container.visible = false
	message.visible = true

	active_trees.clear()
	item_list.clear()
	graph.beehave_tree = {}


func register_tree(data: Dictionary) -> void:
	if not active_trees.has(data.id):
		var idx := item_list.add_item(data.name, TREE_ICON)
		item_list.set_item_tooltip(idx, data.path)
		item_list.set_item_metadata(idx, data.id)
		
	active_trees[data.id] = data

	var id_int = data.id.to_int()
	if active_tree_id == id_int:
		graph.beehave_tree = data
		
		# Re-send activation if this is our active tree
		if session != null and visible and is_visible_in_tree():
			session.send_message("beehave:visibility_changed", [true])
			session.send_message("beehave:activate_tree", [id_int])
	
	# If no item is selected or this is the first item, select it
	if item_list.get_selected_items().is_empty():
		var idx_to_select := 0
		for i in range(item_list.item_count):
			if item_list.get_item_metadata(i) == data.id:
				idx_to_select = i
				break
		
		item_list.select(idx_to_select)
		# This will trigger _on_item_selected to send activation messages
		
		# For extra robustness, especially on first run, explicitly call _on_item_selected
		# after a short delay to ensure the UI is updated
		get_tree().create_timer(0.2).timeout.connect(func():
			if item_list.is_inside_tree() and item_list.item_count > 0 and not item_list.get_selected_items().is_empty():
				var selected_idx = item_list.get_selected_items()[0]
				_on_item_selected(selected_idx)
		)


func unregister_tree(instance_id: int) -> void:
	var id := str(instance_id)
	for i in item_list.item_count:
		if item_list.get_item_metadata(i) == id:
			item_list.remove_item(i)
			break

	active_trees.erase(id)

	if graph.beehave_tree.get("id", "") == id:
		graph.beehave_tree = {}


func _on_toggle_button_pressed(toggle_button: Button) -> void:
	item_list.visible = !item_list.visible
	toggle_button.icon = get_theme_icon(
		&"Back" if item_list.visible else &"Forward", &"EditorIcons"
	)


func _on_item_selected(idx: int) -> void:
	if idx < 0 or idx >= item_list.item_count:
		return
		
	var id: StringName = item_list.get_item_metadata(idx)
	if id == null or id == "":
		return
		
	var tree_data = active_trees.get(id, {})
	if tree_data.is_empty():
		return
		
	graph.beehave_tree = tree_data

	# Clear out any loaded blackboards
	for child in blackboard_vbox.get_children():
		child.free()

	active_tree_id = id.to_int()
	
	# First send the visibility state, then activate the tree
	if session != null:
		var is_visible = visible and is_visible_in_tree()
		
		# Always send visibility first to ensure the global debugger is in the correct state
		session.send_message("beehave:visibility_changed", [is_visible])
		
		# Send activation message
		session.send_message("beehave:activate_tree", [active_tree_id])
		
		# For extra robustness, send another visibility message after a short delay
		# This helps ensure the visibility state is correctly applied
		get_tree().create_timer(0.1).timeout.connect(func():
			if session != null and is_visible_in_tree():
				session.send_message("beehave:visibility_changed", [true])
		)

func _on_graph_node_selected(node: GraphNode) -> void:
	var node_blackboard: VBoxContainer = NewNodeBlackBoard.new(BeehaveUtils.get_frames(), node)
	blackboard_vbox.add_child(node_blackboard)

func _on_graph_node_deselected(node: GraphNode) -> void:
	var matches: Array = blackboard_vbox\
		.get_children()\
		.filter(func (child): return child.name == node.name)

	for child in matches:
		child.free()


func _on_visibility_changed() -> void:
	var is_visible = visible and is_visible_in_tree()
	
	if session != null:
		session.send_message("beehave:visibility_changed", [is_visible])
		
		# If a tree is already selected, resend the activation message when visibility changes
		if active_tree_id != -1:
			session.send_message("beehave:activate_tree", [active_tree_id])
			
			# For extra robustness, send another activation+visibility message after a short delay
			# This helps ensure the state is correctly applied
			if is_visible:
				get_tree().create_timer(0.2).timeout.connect(func():
					if session != null and is_visible_in_tree() and active_tree_id != -1:
						session.send_message("beehave:visibility_changed", [true])
						session.send_message("beehave:activate_tree", [active_tree_id])
				)
