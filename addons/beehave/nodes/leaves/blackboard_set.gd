@tool
class_name BlackboardSetAction extends ActionLeaf


@export var key: String = ""
@export var value: String = ""


@onready var _expression: Expression = parse_expression(value)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var result: Variant = _expression.execute([], blackboard)
	if _expression.has_execute_failed():
		return FAILURE
	blackboard.set_value(key, result)
	return SUCCESS

