## This node will return SUCCESS if a key exists in the blackboard, or FAILURE
## otherwise.
@tool
class_name BlackboardHasCondition extends BlackboardNode

## The blackboard key to check if it exists.
@export var blackboard_key_expression: String
## If no [member blackboard_name] is specified, [code]"default"[/code] is going
## to be used.
@export var blackboard_name: String = ""

func tick(actor: Node, blackboard: Blackboard) -> int:
  var blackboard_name_ = "default"
  if not blackboard_name.is_empty():
    blackboard_name_ = blackboard_name

  var result = parse_expression(blackboard_key_expression)
  if result[0]:
    return FAILURE
  
  var blackboard_key = result[1]
  if blackboard.has_value(blackboard_key, blackboard_name_):
    return SUCCESS
  return FAILURE
