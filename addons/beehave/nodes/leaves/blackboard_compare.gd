@tool
class_name BlackboardCompareCondition extends ConditionLeaf

## Compares two values using the specified comparison operator.
## Returns [code]FAILURE[/code] if any of the expression fails or the
## comparison operation returns [code]false[/code], otherwise it returns [code]SUCCESS[/code].

enum Operators {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	LESS,
	GREATER_EQUAL,
	LESS_EQUAL,
}


## Expression represetning left operand.
## This value can be any valid GDScript expression.
## In order to use the existing blackboard keys for comparison,
## use get_value("key_name") e.g. get_value("direction").length()
@export_placeholder(EXPRESSION_PLACEHOLDER) var left_operand: String = ""
## Comparison operator.
@export_enum("==", "!=", ">", "<", ">=", "<=") var operator: int = 0
## Expression represetning right operand.
## This value can be any valid GDScript expression.
## In order to use the existing blackboard keys for comparison,
## use get_value("key_name") e.g. get_value("direction").length()
@export_placeholder(EXPRESSION_PLACEHOLDER) var right_operand: String = ""


@onready var _left_expression: Expression = _parse_expression(left_operand)
@onready var _right_expression: Expression = _parse_expression(right_operand)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var left: Variant = _left_expression.execute([], blackboard)
	
	if _left_expression.has_execute_failed():
		return FAILURE
	
	var right: Variant = _right_expression.execute([], blackboard)
	
	if _right_expression.has_execute_failed():
		return FAILURE
	
	var result: bool = false
	
	match operator:
		Operators.EQUAL:            result = left == right
		Operators.NOT_EQUAL:        result = left != right
		Operators.GREATER:          result = left > right
		Operators.LESS:             result = left < right
		Operators.GREATER_EQUAL:    result = left >= right
		Operators.LESS_EQUAL:       result = left <= right
	
	return SUCCESS if result else FAILURE


func _get_expression_sources() -> Array[String]:
	return [left_operand, right_operand]
