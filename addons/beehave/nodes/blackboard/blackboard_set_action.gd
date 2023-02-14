## This node will set the value of a [member blackboard_key_expression] in the
## blackboard specified by [member blackboard_name] to a specified
## [member blackboard_value] or a defined [member blackboard_value_expression].
@tool
class_name BlackboardSetAction extends BlackboardNode

## The blackboard key to set the value to.
@export var blackboard_key_expression: String
## The value to set to the blackboard.
@export var blackboard_value_expression: String
## If no [member blackboard_name] is specified, [code]"default"[/code] is going
## to be used.
@export var blackboard_name: String = ""

func tick(actor: Node, blackboard: Blackboard) -> int:
  var blackboard_name_ = "default"
  if not blackboard_name.is_empty():
    blackboard_name_ = blackboard_name

  var key_result = parse_expression(blackboard_key_expression)
  if key_result[0]:
    return FAILURE
  var value_result = parse_expression(blackboard_value_expression)
  if value_result[0]:
    return FAILURE

  var key = key_result[1]
  var value = value_result[1]

  blackboard.set_value(key, value, blackboard_name_)
  return SUCCESS
