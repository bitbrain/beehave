class_name BlackboardHasCondition extends ConditionLeaf


@export var key: String = ""


func tick(actor: Node, blackboard: Blackboard) -> int:
	return SUCCESS if blackboard.has_value(key) else FAILURE

