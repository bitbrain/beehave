class_name BlackboardNode extends Leaf

## Used to parse expressions so that they can be used as blackboard keys or
## values.
var expression: = Expression.new()

## Returns an array [code]res[/code] with [code]res[0][/code] being a
## [code]bool[/code] which is [code]true[/code] if an error has occurred, and
## [code]res[1][/code] being the parsing result in case there was no error, or
## [code]null[/code] otherwise.
func parse_expression(expression_string: String):
  var error = expression.parse(expression_string)
  if error != OK:
    printerr(expression.get_error_text())
    return [true, null]
  var result = expression.execute()
  if expression.has_execute_failed():
    printerr("Expression failed to execute in %s: %s" % [name, expression_string])
    return [true, null]
  return [false, result]
