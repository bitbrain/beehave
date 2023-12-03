@tool
class_name BlackboardHasCondition extends ConditionLeaf

## Returns [code]FAILURE[/code] if expression execution fails or the specified key doesn't exist.
## Returns [code]SUCCESS[/code] if blackboard has the specified key.

## Expression representing a blackboard key.
@export_placeholder(EXPRESSION_PLACEHOLDER) var key: String = ""

@onready var _key_expression: Expression = _parse_expression(key)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var key_value: Variant = _key_expression.execute([], blackboard)
	
	if _key_expression.has_execute_failed():
		return FAILURE
	
	return SUCCESS if blackboard.has_value(key_value) else FAILURE


func _get_expression_sources() -> Array[String]:
	return [key]
