class_name BlackboardSetAction extends ActionLeaf


@export var key: String = ""
@export var value: String = ""


@onready var expression: Expression = parse_expression(value)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var result: Variant = expression.execute()
	if expression.has_execute_failed():
		return FAILURE
	blackboard.set(key, result)
	return SUCCESS

