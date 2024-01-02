class_name TreeNode
extends RefCounted

# Based on https://rachel53461.wordpress.com/2014/04/20/algorithm-for-drawing-trees/

const SIBLING_DISTANCE: float = 20.0
const LEVEL_DISTANCE: float = 40.0

const BeehaveUtils := preload("res://addons/beehave/utils/utils.gd")

var x: float
var y: float
var mod: float
var parent: TreeNode
var children: Array[TreeNode]

var item: GraphNode


func _init(p_item: GraphNode = null, p_parent: TreeNode = null) -> void:
	parent = p_parent
	item = p_item


func is_leaf() -> bool:
	return children.is_empty()


func is_most_left() -> bool:
	if not parent:
		return true
	return parent.children.front() == self


func is_most_right() -> bool:
	if not parent:
		return true
	return parent.children.back() == self


func get_previous_sibling() -> TreeNode:
	if not parent or is_most_left():
		return null
	return parent.children[parent.children.find(self) - 1]


func get_next_sibling() -> TreeNode:
	if not parent or is_most_right():
		return null
	return parent.children[parent.children.find(self) + 1]


func get_most_left_sibling() -> TreeNode:
	if not parent:
		return null

	if is_most_left():
		return self

	return parent.children.front()


func get_most_left_child() -> TreeNode:
	if children.is_empty():
		return null
	return children.front()


func get_most_right_child() -> TreeNode:
	if children.is_empty():
		return null
	return children.back()


func update_positions(horizontally: bool = false) -> void:
	_initialize_nodes(self, 0)
	_calculate_initial_x(self)

	_check_all_children_on_screen(self)
	_calculate_final_positions(self, 0)

	if horizontally:
		_swap_x_y(self)
		_calculate_x(self, 0)
	else:
		_calculate_y(self, 0)


func _initialize_nodes(node: TreeNode, depth: int) -> void:
	node.x = -1
	node.y = depth
	node.mod = 0

	for child in node.children:
		_initialize_nodes(child, depth + 1)


func _calculate_initial_x(node: TreeNode) -> void:
	for child in node.children:
		_calculate_initial_x(child)
	if node.is_leaf():
		if not node.is_most_left():
			node.x = node.get_previous_sibling().x + node.get_previous_sibling().item.layout_size + SIBLING_DISTANCE
		else:
			node.x = 0
	else:
		var mid: float
		if node.children.size() == 1:
			var offset: float = (node.children.front().item.layout_size - node.item.layout_size) / 2
			mid = node.children.front().x + offset
		else:
			var left_child := node.get_most_left_child()
			var right_child := node.get_most_right_child()
			mid = (left_child.x + right_child.x + right_child.item.layout_size - node.item.layout_size) / 2

		if node.is_most_left():
			node.x = mid
		else:
			node.x = node.get_previous_sibling().x + node.get_previous_sibling().item.layout_size + SIBLING_DISTANCE
			node.mod = node.x - mid

	if not node.is_leaf() and not node.is_most_left():
		_check_for_conflicts(node)


func _calculate_final_positions(node: TreeNode, mod_sum: float) -> void:
	node.x += mod_sum
	mod_sum += node.mod

	for child in node.children:
		_calculate_final_positions(child, mod_sum)


func _check_all_children_on_screen(node: TreeNode) -> void:
	var node_contour: Dictionary = {}
	_get_left_contour(node, 0, node_contour)

	var shift_amount: float = 0
	for y in node_contour.keys():
		if node_contour[y] + shift_amount < 0:
			shift_amount = (node_contour[y] * -1)

	if shift_amount > 0:
		node.x += shift_amount
		node.mod += shift_amount


func _check_for_conflicts(node: TreeNode) -> void:
	var min_distance := SIBLING_DISTANCE
	var shift_value: float = 0
	var shift_sibling: TreeNode = null

	var node_contour: Dictionary = {}# { int, float }
	_get_left_contour(node, 0, node_contour)

	var sibling := node.get_most_left_sibling()
	while sibling != null and sibling != node:
		var sibling_contour: Dictionary = {}
		_get_right_contour(sibling, 0, sibling_contour)

		for level in range(node.y + 1, min(sibling_contour.keys().max(), node_contour.keys().max()) + 1):
			var distance: float = node_contour[level] - sibling_contour[level]
			if distance + shift_value < min_distance:
				shift_value = min_distance - distance
				shift_sibling = sibling

		sibling = sibling.get_next_sibling()

	if shift_value > 0:
		node.x += shift_value
		node.mod += shift_value
		_center_nodes_between(shift_sibling, node)


func _center_nodes_between(left_node: TreeNode, right_node: TreeNode) -> void:
	var left_index := left_node.parent.children.find(left_node)
	var right_index := left_node.parent.children.find(right_node)

	var num_nodes_between: int = (right_index - left_index) - 1
	if num_nodes_between > 0:
		# The extra distance that needs to be split into num_nodes_between + 1
		# in order to find the new node spacing so that nodes are equally spaced
		var distance_to_allocate: float = right_node.x - left_node.x - left_node.item.layout_size
		# Subtract sizes on nodes in between
		for i in range(left_index + 1, right_index):
			distance_to_allocate -= left_node.parent.children[i].item.layout_size
		# Divide space equally
		var distance_between_nodes: float = distance_to_allocate / (num_nodes_between + 1)

		var prev_node := left_node
		var middle_node := left_node.get_next_sibling()
		while middle_node != right_node:
			var desire_x: float = prev_node.x + prev_node.item.layout_size + distance_between_nodes
			var offset := desire_x - middle_node.x
			middle_node.x += offset
			middle_node.mod += offset
			prev_node = middle_node
			middle_node = middle_node.get_next_sibling()


func _get_left_contour(node: TreeNode, mod_sum: float, values: Dictionary) -> void:
	var node_left: float = node.x + mod_sum
	var depth := int(node.y)
	if not values.has(depth):
		values[depth] = node_left
	else:
		values[depth] = min(values[depth], node_left)

	mod_sum += node.mod
	for child in node.children:
		_get_left_contour(child, mod_sum, values)


func _get_right_contour(node: TreeNode, mod_sum: float, values: Dictionary) -> void:
	var node_right: float = node.x + mod_sum + node.item.layout_size
	var depth := int(node.y)
	if not values.has(depth):
		values[depth] = node_right
	else:
		values[depth] = max(values[depth], node_right)

	mod_sum += node.mod
	for child in node.children:
		_get_right_contour(child, mod_sum, values)


func _swap_x_y(node: TreeNode) -> void:
	for child in node.children:
		_swap_x_y(child)

	var temp := node.x
	node.x = node.y
	node.y = temp


func _calculate_x(node: TreeNode, offset: int) -> void:
	node.x = offset
	var sibling := node.get_most_left_sibling()
	var max_size: int = node.item.size.x
	while sibling != null:
		max_size = max(sibling.item.size.x, max_size)
		sibling = sibling.get_next_sibling()

	for child in node.children:
		_calculate_x(child, max_size + offset + LEVEL_DISTANCE * BeehaveUtils.get_editor_scale())


func _calculate_y(node: TreeNode, offset: int) -> void:
	node.y = offset
	var sibling := node.get_most_left_sibling()
	var max_size: int = node.item.size.y
	while sibling != null:
		max_size = max(sibling.item.size.y, max_size)
		sibling = sibling.get_next_sibling()

	for child in node.children:
		_calculate_y(child, max_size + offset + LEVEL_DISTANCE * BeehaveUtils.get_editor_scale())
