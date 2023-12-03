@tool
extends BeehaveTree


@export_range(1, 100) var randomize_node_count: int = 20
@export var randomize_tree: bool = false:
	set(v):
		if !v:
			return
		randomize_tree = false
		_randomize_tree()


class TNode extends RefCounted:
	var children = []


var long_name_suffix = "LooooooooongNameSuffix"


func get_name_suffix():
	var r = randi_range(0, 0)
	if r:
		return long_name_suffix
	return ""

var tree_root: TNode
var tree_nodes = []

func _get_random_node():
	return tree_nodes[randi_range(0, tree_nodes.size() - 1)]

func _make_random_tree():
	# One node (the root) is already created
	tree_root = TNode.new()
	tree_nodes = [tree_root]
	for i in randomize_node_count - 1:
		var n = _get_random_node()
		var new_node = TNode.new()
		n.children.append(new_node)
		tree_nodes.append(new_node)


func _parse_tree_node(parent, node, index: int):
	var n
	if node.children.size() > 1:
		n = SelectorReactiveComposite.new()
		n.name = "SelectorReactiveComposite%s-%d" % [get_name_suffix(), index]
	elif node.children.size() == 1:
		n = InverterDecorator.new()
		n.name = "InverterDecorator%s-%d" % [get_name_suffix(), index]
	else:
		n = RandomAction.new()
		n.name = "RandomAction%s-%d" % [get_name_suffix(), index]
	parent.add_child(n)
	if Engine.is_editor_hint():
		n.owner = get_tree().get_edited_scene_root()
	var i = 0
	for ch in node.children:
		_parse_tree_node(n, ch, i)
		i += 1


func _randomize_tree():
	for ch in get_children():
		remove_child(ch)
		ch.queue_free()
	_make_random_tree()
	_parse_tree_node(self, tree_root, 0)
