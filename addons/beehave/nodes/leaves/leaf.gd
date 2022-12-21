## Base class for all leaf nodes of the tree.
@tool
class_name Leaf extends BeehaveNode
@icon("../../icons/category_leaf.svg")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var children: Array[Node] = get_children()
	
	if children.any(func(x): return x is BeehaveNode):
		warnings.append("Leaf nodes should not have any child nodes. They won't be ticked.")
	
	return warnings
