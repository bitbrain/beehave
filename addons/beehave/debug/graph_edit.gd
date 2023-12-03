@tool
extends GraphEdit

const BeehaveGraphNode := preload("graph_node.gd")

const HORIZONTAL_LAYOUT_ICON := preload("icons/horizontal_layout.svg")
const VERTICAL_LAYOUT_ICON := preload("icons/vertical_layout.svg")

const PROGRESS_SHIFT: int = 50
const INACTIVE_COLOR: Color = Color("#898989aa")
const ACTIVE_COLOR: Color = Color("#ffcc00c8")
const SUCCESS_COLOR: Color = Color("#009944c8")


var updating_graph: bool = false
var arraging_nodes: bool = false
var beehave_tree: Dictionary:
	set(value):
		if beehave_tree == value:
			return
		beehave_tree = value
		active_nodes.clear()
		_update_graph()

var horizontal_layout: bool = false:
	set(value):
		if updating_graph or arraging_nodes:
			return
		if horizontal_layout == value:
			return
		horizontal_layout = value
		_update_layout_button()
		_update_graph()


var frames:RefCounted
var active_nodes: Array[String]
var progress: int = 0
var layout_button: Button


func _init(frames:RefCounted) -> void:
	self.frames = frames


func _ready() -> void:
	custom_minimum_size = Vector2(100, 300)
	# Godot 4.2+
	if "show_arrange_button" in self:
		set("show_arrange_button", true)
	else:
		set("arrange_nodes_button_hidden", true)
	minimap_enabled = false
	layout_button = Button.new()
	layout_button.flat = true
	layout_button.focus_mode = Control.FOCUS_NONE
	layout_button.pressed.connect(func(): horizontal_layout = not horizontal_layout)
	get_menu_container().add_child(layout_button)
	_update_layout_button()


func _update_graph() -> void:
	if updating_graph:
		return

	updating_graph = true

	clear_connections()

	for child in _get_child_nodes():
		remove_child(child)
		child.queue_free()

	if not beehave_tree.is_empty():
		_add_nodes(beehave_tree)
		_connect_nodes(beehave_tree)
		_arrange_nodes.call_deferred(beehave_tree)

	updating_graph = false


func _add_nodes(node: Dictionary) -> void:
	if node.is_empty():
		return
	var gnode := BeehaveGraphNode.new(frames, horizontal_layout)
	add_child(gnode)
	gnode.title_text = node.name
	gnode.name = node.id
	gnode.icon = _get_icon(node.type.back())

	if node.type.has(&"BeehaveTree"):
		gnode.set_slots(false, true)
	elif node.type.has(&"Leaf"):
		gnode.set_slots(true, false)
	elif node.type.has(&"Composite") or node.type.has(&"Decorator"):
		gnode.set_slots(true, true)

	for child in node.get("children", []):
		_add_nodes(child)


func _connect_nodes(node: Dictionary) -> void:
	for child in node.get("children", []):
		connect_node(node.id, 0, child.id, 0)
		_connect_nodes(child)


func _arrange_nodes(node: Dictionary) -> void:
	if arraging_nodes:
		return

	arraging_nodes = true

	var tree_node := _create_tree_nodes(node)
	tree_node.update_positions(horizontal_layout)
	_place_nodes(tree_node)

	arraging_nodes = false


func _create_tree_nodes(node: Dictionary, root: TreeNode = null) -> TreeNode:
	var tree_node := TreeNode.new(get_node(node.id), root)
	for child in node.get("children", []):
		var child_node := _create_tree_nodes(child, tree_node)
		tree_node.children.push_back(child_node)
	return tree_node


func _place_nodes(node: TreeNode) -> void:
	node.item.position_offset = Vector2(node.x, node.y)
	for child in node.children:
		_place_nodes(child)


func _get_icon(type: StringName) -> Texture2D:
	var classes := ProjectSettings.get_global_class_list()
	for c in classes:
		if c["class"] == type:
			var icon_path := c.get("icon", String())
			if not icon_path.is_empty():
				return load(icon_path)
	return null


func get_menu_container() -> Control:
	# Godot 4.0+
	if has_method("get_zoom_hbox"):
		return call("get_zoom_hbox")

	# Godot 4.2+
	return call("get_menu_hbox")


func get_status(status: int) -> String:
	if status == 0:
		return "SUCCESS"
	elif status == 1:
		return "FAILURE"
	return "RUNNING"


func process_begin(instance_id: int) -> void:
	if not _is_same_tree(instance_id):
		return

	for child in _get_child_nodes():
		child.set_meta("status", -1)


func process_tick(instance_id: int, status: int) -> void:
	var node := get_node_or_null(str(instance_id))
	if node:
		node.text = "Status: %s" % get_status(status)
		node.set_status(status)
		node.set_meta("status", status)
		if status == 0 or status == 2:
			if not active_nodes.has(node.name):
				active_nodes.push_back(node.name)


func process_end(instance_id: int) -> void:
	if not _is_same_tree(instance_id):
		return

	for child in _get_child_nodes():
		var status := child.get_meta("status", -1)
		match status:
			0:
				active_nodes.erase(child.name)
				child.set_color(SUCCESS_COLOR)
			1:
				active_nodes.erase(child.name)
				child.set_color(INACTIVE_COLOR)
			2:
				child.set_color(ACTIVE_COLOR)
			_:
				child.text = " "
				child.set_status(status)
				child.set_color(INACTIVE_COLOR)


func _is_same_tree(instance_id: int) -> bool:
	return str(instance_id) == beehave_tree.get("id", "")


func _get_child_nodes() -> Array[Node]:
	return get_children().filter(func(child): return child is BeehaveGraphNode)


func _get_connection_line(from_position: Vector2, to_position: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array

	from_position = from_position.round()
	to_position = to_position.round()

	points.push_back(from_position)

	var mid_position := ((to_position + from_position) / 2).round()
	if horizontal_layout:
		points.push_back(Vector2(mid_position.x, from_position.y))
		points.push_back(Vector2(mid_position.x, to_position.y))
	else:
		points.push_back(Vector2(from_position.x, mid_position.y))
		points.push_back(Vector2(to_position.x, mid_position.y))

	points.push_back(to_position)

	return points


func _process(delta: float) -> void:
	if not active_nodes.is_empty():
		progress += 10 if delta >= 0.05 else 1
		if progress >= 1000:
			progress = 0
		queue_redraw()


func _draw() -> void:
	if active_nodes.is_empty():
		return

	var circle_size: float = max(3, 6 * zoom)
	var progress_shift: float = PROGRESS_SHIFT * zoom

	var connections := get_connection_list()
	for c in connections:
		var from_node: StringName
		var to_node: StringName

		# Godot 4.0+
		if c.has("from"):
			from_node = c.from
			to_node = c.to
		# Godot 4.2+
		else:
			from_node = c.from_node
			to_node = c.to_node

		if not from_node in active_nodes or not c.to_node in active_nodes:
			continue

		var from := get_node(String(from_node))
		var to := get_node(String(to_node))

		if from.get_meta("status", -1) < 0 or to.get_meta("status", -1) < 0:
			return

		var output_port_position: Vector2
		var input_port_position: Vector2

		# Godot 4.0+
		if from.has_method("get_connection_output_position"):
			output_port_position = from.position + from.call("get_connection_output_position", c.from_port)
			input_port_position = to.position + to.call("get_connection_input_position", c.to_port)
		# Godot 4.2+
		else:
			output_port_position = from.position + from.call("get_output_port_position", c.from_port)
			input_port_position = to.position + to.call("get_input_port_position", c.to_port)

		var line := _get_connection_line(output_port_position, input_port_position)

		var curve = Curve2D.new()
		for l in line:
			curve.add_point(l)

		var max_steps := int(curve.get_baked_length())
		var current_shift := progress % max_steps
		var p := curve.sample_baked(current_shift)
		draw_circle(p, circle_size, ACTIVE_COLOR)

		var shift := current_shift - progress_shift
		while shift >= 0:
			draw_circle(curve.sample_baked(shift), circle_size, ACTIVE_COLOR)
			shift -= progress_shift

		shift = current_shift + progress_shift
		while shift <= curve.get_baked_length():
			draw_circle(curve.sample_baked(shift), circle_size, ACTIVE_COLOR)
			shift += progress_shift


func _update_layout_button() -> void:
	layout_button.icon = VERTICAL_LAYOUT_ICON if horizontal_layout else HORIZONTAL_LAYOUT_ICON
	layout_button.tooltip_text = "Switch to Vertical layout" if horizontal_layout else "Switch to Horizontal layout"
