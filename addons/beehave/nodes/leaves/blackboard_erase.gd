@tool
class_name BlackboardEraseAction extends ActionLeaf

## Erases the specified key from the blackboard.
## Returns [code]FAILURE[/code] if expression execution fails, otherwise [code]SUCCESS[/code].

## Expression representing a blackboard key.
@export_placeholder(EXPRESSION_PLACEHOLDER) var key: String = ""

@onready var _key_expression: Expression = _parse_expression(key)


func tick(actor: Node, blackboard: Blackboard) -> int:
	var key_value: Variant = _key_expression.execute([], blackboard)
	
	if _key_expression.has_execute_failed():
		return FAILURE
	
	blackboard.erase_value(key_value)
	
	return SUCCESS


func _get_expression_sources() -> Array[String]:
	return [key]
