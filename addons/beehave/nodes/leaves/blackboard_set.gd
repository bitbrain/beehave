@tool
class_name BlackboardSetAction extends ActionLeaf


@export var key: String = ""
@export var value: String = ""


@onready var _expression: Expression = parse_expression(value)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var result: Variant = _expression.execute([], blackboard)
	
	assert(
		not _expression.has_execute_failed(),
		"[BlackboardSetAction] Expression execution failed in node: `%s`! Source: `%s`" % [name, value]
	)
	
	blackboard.set_value(key, result)
	return SUCCESS

