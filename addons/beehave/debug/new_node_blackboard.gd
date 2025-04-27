extends VBoxContainer

var frames: RefCounted
var graph_node: GraphNode

var item_tree: Tree

func _init(frames: RefCounted, node: GraphNode) -> void:
	self.frames = frames
	graph_node = node

	graph_node.blackboard_updated.connect(_update_list)

func _ready() -> void:
	name = graph_node.name

	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title_panel: Panel = Panel.new()
	title_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_panel.custom_minimum_size = Vector2(200, 50)
	add_child(title_panel)
	var title_hbox: HBoxContainer = HBoxContainer.new()
	title_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	title_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_panel.add_child(title_hbox)

	var icon_rect: TextureRect = TextureRect.new()
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture = graph_node.icon
	icon_rect.set_size(Vector2(20, 20))
	title_hbox.add_child(icon_rect)

	var title: Label = Label.new()
	title.text = graph_node.title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_hbox.add_child(title)

	item_tree = Tree.new()
	item_tree.custom_minimum_size = Vector2(200, 400)
	item_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_tree.hide_root = true
	item_tree.allow_search = false
	item_tree.columns = 2
	add_child(item_tree)

	_update_list()

func _update_list() -> void:
	item_tree.clear()

	var root: TreeItem = item_tree.create_item()

	if graph_node.blackboard.size() == 0:
		var no_bb_message: TreeItem = item_tree.create_item(root)
		no_bb_message.set_text(0, "No blackboard data")
		return

	for bb_name in graph_node.blackboard:
		var bb_name_branch: TreeItem = item_tree.create_item(root)
		bb_name_branch.set_text(0, bb_name)

		#print(graph_node.blackboard.get(bb_name))
		for key in graph_node.blackboard.get(bb_name):
			var bb_kv_leaf: TreeItem = item_tree.create_item(bb_name_branch)
			bb_kv_leaf.set_text(0, str(key))
			bb_kv_leaf.set_text(1, str(graph_node.blackboard.get(bb_name).get(key)))

func _get_icon(type: StringName) -> Texture2D:
	var classes := ProjectSettings.get_global_class_list()
	for c in classes:
		if c["class"] == type:
			var icon_path := c.get("icon", String())
			if not icon_path.is_empty():
				return load(icon_path)
	return null
