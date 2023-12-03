class_name ClearCountAction extends ActionLeaf

@export var key = "custom_value"

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value(key):
		blackboard.erase_value(key)
		return SUCCESS
	else:
		return FAILURE
