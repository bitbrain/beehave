@tool
class_name BlackboardCompareCondition extends ConditionLeaf


enum Operators {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	LESS,
	GREATER_EQUAL,
	LESS_EQUAL,
}


@export var left_operand: String = ""
@export_enum("==", "!=", ">", "<", ">=", "<=") var operator: int = 0
@export var right_operand: String = ""


@onready var _left_expression: Expression = parse_expression(left_operand)
@onready var _right_expression: Expression = parse_expression(right_operand)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var left: Variant = _left_expression.execute([], blackboard)
	
	assert(
		not _left_expression.has_execute_failed(),
		"[BlackboardCompareCondition] Expression execution failed in node: `%s`! Source: `%s`" % [name, left_operand]
	)
	
	var right: Variant = _right_expression.execute([], blackboard)
	
	assert(
		not _right_expression.has_execute_failed(),
		"[BlackboardCompareCondition] Expression execution failed in node: `%s`! Source: `%s`" % [name, right_operand]
	)
	
	var result: bool = false
	
	match operator:
		Operators.EQUAL:            result = left == right
		Operators.NOT_EQUAL:        result = left != right
		Operators.GREATER:          result = left > right
		Operators.LESS:             result = left < right
		Operators.GREATER_EQUAL:    result = left >= right
		Operators.LESS_EQUAL:       result = left <= right
	
	return SUCCESS if result else FAILURE

