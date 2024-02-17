class_name ClearCountAction extends BeehaveAction

@export var key = "custom_value"

func tick(_context: BeehaveContext) -> int:
	if blackboard.has_value(key):
		blackboard.erase_value(key)
		return SUCCESS
	else:
		return FAILURE
