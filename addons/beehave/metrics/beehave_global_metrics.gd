extends Node

var _tree_count: int = 0
var _active_tree_count: int = 0
var _registered_trees: Array = []


func _enter_tree() -> void:
	Performance.add_custom_monitor("beehave/total_trees", _get_total_trees)
	Performance.add_custom_monitor("beehave/total_enabled_trees", _get_total_enabled_trees)


func register_tree(tree) -> void:
	if _registered_trees.has(tree):
		return
	
	_registered_trees.append(tree)
	_tree_count += 1
	
	if tree.enabled:
		_active_tree_count += 1
	
	tree.tree_enabled.connect(_on_tree_enabled)
	tree.tree_disabled.connect(_on_tree_disabled)


func unregister_tree(tree) -> void:
	if not _registered_trees.has(tree):
		return
	
	_registered_trees.erase(tree)
	_tree_count -= 1
	
	if tree.enabled:
		_active_tree_count -= 1
	
	tree.tree_enabled.disconnect(_on_tree_enabled)
	tree.tree_disabled.disconnect(_on_tree_disabled)


func _get_total_trees() -> int:
	return _tree_count

	
func _get_total_enabled_trees() -> int:
	return _active_tree_count


func _on_tree_enabled() -> void:
	_active_tree_count += 1


func _on_tree_disabled() -> void:
	_active_tree_count -= 1
