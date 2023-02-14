## This node will erase a [member blackboard_key] in the blackboard
## specified by [member blackboard_name], if it exists.
@tool
class_name BlackboardEraseAction extends BlackboardNode

## The blackboard key to erase.
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
  blackboard.erase_value(blackboard_key, blackboard_name_)
  return SUCCESS
