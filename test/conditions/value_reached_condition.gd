class_name ValueReachedCondition extends ConditionLeaf

@export var limit = 2
@export var key = "custom_value"

func tick(_context: BeehaveContext) -> int:
	if blackboard.get_value(key, 0) >= limit:
		return SUCCESS
	else:
		return FAILURE
