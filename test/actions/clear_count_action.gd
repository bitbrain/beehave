class_name ClearCountAction extends ActionLeaf

@export var key = "custom_value"

func tick(actor: Node, blackboard: Blackboard, delta: float) -> int:
	if blackboard.has_value(key):
		blackboard.erase_value(key)
		return SUCCESS
	else:
		return FAILURE
