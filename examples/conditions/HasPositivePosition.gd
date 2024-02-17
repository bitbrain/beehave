class_name HasPositivePosition extends ConditionLeaf


func tick(context: BeehaveContext) -> int:
	if actor.position.x > 0.0 and actor.position.y > 0.0:
		return SUCCESS
	else:
		return FAILURE

