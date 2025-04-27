extends Node

var _registered_trees: Dictionary
var _active_tree
var _pending_activation_id: int = -1 # Store the ID if activation arrives before registration
var _editor_visible: bool = false # Track editor visibility


func _enter_tree() -> void:
	EngineDebugger.register_message_capture("beehave", _on_debug_message)


func _on_debug_message(message: String, data: Array) -> bool:
	match message:
		"activate_tree":
			var requested_id: int = data[0]
			_set_active_tree(requested_id)
			return true
		"visibility_changed":
			_editor_visible = data[0]
			if _active_tree and is_instance_valid(_active_tree):
				# Only update _can_send_message based on editor visibility
				_active_tree._can_send_message = _editor_visible
			elif _pending_activation_id != -1:
				# If we have a pending activation and visibility changes, try to activate it again
				_set_active_tree(_pending_activation_id)
			return true
	return false


func _set_active_tree(tree_id: int) -> void:
	var tree = _registered_trees.get(tree_id, null)

	if tree and is_instance_valid(tree):
		# Tree found, proceed with activation
		if _active_tree and is_instance_valid(_active_tree):
			_active_tree._can_send_message = false # Deactivate old one
		_active_tree = tree
		# Activate the new tree ONLY if the editor debugger tab is actually visible
		_active_tree._can_send_message = _editor_visible
		
		# If this was the pending ID, clear it
		if _pending_activation_id == tree_id:
			_pending_activation_id = -1
	else:
		# Tree not found (yet), mark it as pending activation
		_pending_activation_id = tree_id

		if _active_tree and is_instance_valid(_active_tree):
			_active_tree._can_send_message = false
		_active_tree = null # No tree is active now


func register_tree(tree) -> void:
	var tree_id = tree.get_instance_id()
	_registered_trees[tree_id] = tree
	
	# Check if this tree was waiting for activation
	if tree_id == _pending_activation_id:
		# Found the pending tree, activate it now
		_set_active_tree(tree_id) # This will set _active_tree and handle _can_send_message


func unregister_tree(tree) -> void:
	var tree_id = tree.get_instance_id()
	_registered_trees.erase(tree_id)
	if _active_tree == tree:
		_active_tree = null
	if _pending_activation_id == tree_id:
		_pending_activation_id = -1
