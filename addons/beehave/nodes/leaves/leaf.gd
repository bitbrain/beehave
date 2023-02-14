## Base class for all leaf nodes of the tree.
@tool
@icon("../../icons/category_leaf.svg")
class_name Leaf extends BeehaveNode


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var children: Array[Node] = get_children()
	
	if children.any(func(x): return x is BeehaveNode):
		warnings.append("Leaf nodes should not have any child nodes. They won't be ticked.")
	
	return warnings


func parse_expression(source: String) -> Expression:
	var result: Expression = Expression.new()
	var error: int = result.parse(source)
	assert(
		error == OK,
		"[Leaf] Invalid expression! Error: `%s` Source: `%s`" % [result.get_error_text(), source]
	)
	return result
