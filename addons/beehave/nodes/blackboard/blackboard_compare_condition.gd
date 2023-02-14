## This node will compare two different keys from the blackboard, using the
## specified [member comparison_type].
@tool
class_name BlackboardCompareCondition extends BlackboardNode

## Defines the type of comparison to perform.
@export var comparison_type: ComparisonType = ComparisonType.Less
## The first blackboard key to compare.
@export var blackboard_key_expression1: String
## The second blackboard key to compare.
@export var blackboard_key_expression2: String
## If no [member blackboard_name] is specified, [code]"default"[/code] is going
## to be used.
@export var blackboard_name: String = ""

enum ComparisonType {
  Less,
  LessOrEqual,
  Greater,
  GreaterOrEqual,
  Equal,
  NotEqual
}

func tick(actor: Node, blackboard: Blackboard) -> int:
  var blackboard_name_ = "default"
  if not blackboard_name.is_empty():
    blackboard_name_ = blackboard_name

  # Parse expressions and get the key values, checking for parse errors
  var result1 = parse_expression(blackboard_key_expression1)
  if result1[0]:
    return FAILURE
  var result2 = parse_expression(blackboard_key_expression1)
  if result2[0]:
    return FAILURE
  var blackboard_key1 = result1[1]
  var blackboard_key2 = result2[1]

  # Use the keys to get the blackboard values to compare them
  var value1 = blackboard.get_value(blackboard_key1, blackboard_name_)
  var value2 = blackboard.get_value(blackboard_key2, blackboard_name_)

  # Compare the values
  var cond = false
  if comparison_type == ComparisonType.Equal:
    cond = (value1 == value2)
  elif comparison_type == ComparisonType.NotEqual:
    cond = (value1 != value2)
  elif comparison_type == ComparisonType.Less:
    cond = (value1 < value2)
  elif comparison_type == ComparisonType.LessOrEqual:
    cond = (value1 <= value2)
  elif comparison_type == ComparisonType.Greater:
    cond = (value1 > value2)
  elif comparison_type == ComparisonType.GreaterOrEqual:
    cond = (value1 >= value2)
  
  if cond:
    return SUCCESS
  return FAILURE
