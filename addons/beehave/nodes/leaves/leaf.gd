@tool
@icon("../../icons/category_leaf.svg")
class_name Leaf extends BeehaveNode

## Base class for all leaf nodes of the tree.

const EXPRESSION_PLACEHOLDER: String = "Insert an expression..."


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	var children: Array[Node] = get_children()

	if children.any(func(x): return x is BeehaveNode):
		warnings.append("Leaf nodes should not have any child nodes. They won't be ticked.")
	
	for source in _get_expression_sources():
		var error_text: String = _parse_expression(source).get_error_text()
		if not error_text.is_empty():
			warnings.append("Expression `%s` is invalid! Error text: `%s`" % [source, error_text])
	
	return warnings


func _parse_expression(source: String) -> Expression:
	var result: Expression = Expression.new()
	var error: int = result.parse(source)
	
	if not Engine.is_editor_hint() and error != OK:
		push_error(
			"[Leaf] Couldn't parse expression with source: `%s` Error text: `%s`" %\
			[source, result.get_error_text()]
		)
	
	return result


func _get_expression_sources() -> Array[String]: # virtual
	return []


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"Leaf")
	return classes
