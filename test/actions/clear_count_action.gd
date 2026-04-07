class_name ClearCountAction extends BeehaveAction

@export var key = "custom_value"

func tick(context: BeehaveContext) -> int:
	if context.get_blackboard().has_value(key):
		context.get_blackboard().erase_value(key)
		return SUCCESS
	else:
		return FAILURE
