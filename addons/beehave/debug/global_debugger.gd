extends Node

var _registered_trees: Dictionary
var _active_tree


func _enter_tree() -> void:
	EngineDebugger.register_message_capture("beehave", _on_debug_message)


func _on_debug_message(message: String, data: Array) -> bool:
	if message == "activate_tree":
		_set_active_tree(data[0])
		return true
	if message == "visibility_changed":
		if _active_tree:
			_active_tree._can_send_message = data[0]
		return true
	return false


func _set_active_tree(tree_id: int) -> void:
	var tree = _registered_trees.get(tree_id, null)
	if not tree:
		return

	if _active_tree:
		_active_tree._can_send_message = false
	_active_tree = tree
	_active_tree._can_send_message = true


func register_tree(tree) -> void:
	_registered_trees[tree.get_instance_id()] = tree


func unregister_tree(tree) -> void:
	_registered_trees.erase(tree.get_instance_id())
