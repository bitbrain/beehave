extends BeehaveCondition
class_name HasNegativePosition


func tick(context: BeehaveContext) -> int:
	if context.actor.position.x < 0.0 and context.actor.position.y < 0.0:
		return SUCCESS
	else:
		return FAILURE
