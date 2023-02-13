class_name TreeNode
extends RefCounted

# Based on https://rachel53461.wordpress.com/2014/04/20/algorithm-for-drawing-trees/

const sibling_distance: float = 20.0
const tree_distance: float = 0

var x: float
var y: int
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


func update_positions() -> void:
	_initialize_nodes(self, 0)
	_calculate_initial_x(self)

	_check_all_children_on_screen(self)
	_calculate_final_positions(self, 0)


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
			node.x = node.get_previous_sibling().x + node.get_previous_sibling().item.size.x + sibling_distance
		else:
			node.x = 0
	elif node.children.size() == 1:
		var offset: float = (node.children.front().item.size.x - node.item.size.x) / 2
		if node.is_most_left():
			node.x = node.children.front().x + offset
		else:
			node.x = node.get_previous_sibling().x + node.item.size.x + sibling_distance
			node.mod = node.x - node.children.front().x - offset
	else:
		var left_child = node.get_most_left_child()
		var right_child = node.get_most_right_child()
		var mid: float = (left_child.x + right_child.x + right_child.item.size.x - node.item.size.x) / 2

		if node.is_most_left():
			node.x = mid
		else:
			node.x = node.get_previous_sibling().x + node.item.size.x + sibling_distance
			node.mod = node.x - mid

	if not node.children.is_empty() and not node.is_most_left():
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
	var min_distance = tree_distance + node.item.size.x
	var shift_value: float = 0

	var node_contour: Dictionary = {}# { int, float }
	_get_left_contour(node, 0, node_contour)

	var sibling := node.get_most_left_sibling()
	while sibling != null and sibling != node:
		var sibling_contour: Dictionary = {}
		_get_right_contour(sibling, 0, sibling_contour)

		for level in range(node.y + 1, min(sibling_contour.keys().max(), node_contour.keys().max()) + 1):
			var distance: float = node_contour[level] - sibling_contour[level]
			if distance + shift_value < min_distance:
				shift_value = max(min_distance - distance, shift_value)

		if shift_value > 0:
			_center_nodes_between(node, sibling)

		sibling = sibling.get_next_sibling()

	if shift_value > 0:
		node.x += shift_value
		node.mod += shift_value
		shift_value = 0


func _center_nodes_between(left_node: TreeNode, right_node: TreeNode) -> void:
	var left_index := left_node.parent.children.find(left_node)
	var right_index := left_node.parent.children.find(right_node)

	var num_nodes_between: int = (left_index - right_index) - 1
	if num_nodes_between > 0:
		var distance_between_nodes: float = (left_node.x - right_node.x) / (num_nodes_between + 1)

		var count: int = 1
		for i in range(left_index + 1, right_index):
			var middle_node := left_node.parent.children[i]
			var desire_x := right_node.x + (distance_between_nodes * count)
			var offset := desire_x - middle_node.x
			middle_node.x += offset
			middle_node.mod += offset

			count += 1
		_check_for_conflicts(left_node)


func _get_left_contour(node: TreeNode, mod_sum: float, values: Dictionary) -> void:
	if not values.has(node.y):
		values[node.y] = node.x + mod_sum
	else:
		values[node.y] = min(values[node.y], node.x + mod_sum)

	mod_sum += node.mod
	for child in node.children:
		_get_left_contour(child, mod_sum, values)


func _get_right_contour(node: TreeNode, mod_sum: float, values: Dictionary) -> void:
	if not values.has(node.y):
		values[node.y] = node.x + mod_sum
	else:
		values[node.y] = max(values[node.y], node.x + mod_sum)

	mod_sum += node.mod
	for child in node.children:
		_get_right_contour(child, mod_sum, values)
