class_name BeehaveDebuggerMessages


static func can_send_message() -> bool:
	return not Engine.is_editor_hint() and OS.has_feature("editor")


static func register_tree(beehave_tree: Dictionary) -> void:
	if can_send_message():
		EngineDebugger.send_message("beehave:register_tree", [beehave_tree])


static func unregister_tree(instance_id: int) -> void:
	if can_send_message():
		EngineDebugger.send_message("beehave:unregister_tree", [instance_id])


static func process_tick(instance_id: int, status: int) -> void:
	if can_send_message():
		EngineDebugger.send_message("beehave:process_tick", [instance_id, status])


static func process_begin(instance_id: int) -> void:
	if can_send_message():
		EngineDebugger.send_message("beehave:process_begin", [instance_id])


static func process_end(instance_id: int) -> void:
	if can_send_message():
		EngineDebugger.send_message("beehave:process_end", [instance_id])

