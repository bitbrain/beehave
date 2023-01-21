## A node in the behaviour tree. Every node must return `SUCCESS`, `FAILURE` or
## `RUNNING` when ticked.
@tool
class_name BeehaveNode extends Node

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

## Executes this node and returns a status code.
## This method must be overwritten.
func tick(actor: Node, blackboard: Blackboard) -> int:
	return SUCCESS


## Called when this node needs to be interrupted before it can return FAILURE or SUCCESS.
func interrupt(actor: Node, blackboard: Blackboard) -> void:
	pass
