## Base class for all parts of the behaviour tree.
@tool
@icon("../icons/category_bt.svg")
class_name BeehaveTree extends Node


enum {
	SUCCESS,
	FAILURE,
	RUNNING
}


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_children().any(func(x): return not (x is BeehaveNode)):
		warnings.append("All children of this node should inherit from BeehaveNode class.")
	
	return warnings
