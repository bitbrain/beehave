@tool
class_name BeehaveNode extends Node

## A node in the behavior tree. Every node must return `SUCCESS`, `FAILURE` or
## `RUNNING` when ticked.

enum { SUCCESS, FAILURE, RUNNING }


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
	BeehaveDebuggerMessages.process_interrupt(self.get_instance_id(), blackboard.get_debug_data())


## Called before the first time it ticks by the parent.
func before_run(actor: Node, blackboard: Blackboard) -> void:
	pass


## Called after the last time it ticks and returns
## [code]SUCCESS[/code] or [code]FAILURE[/code].
func after_run(actor: Node, blackboard: Blackboard) -> void:
	pass


func get_class_name() -> Array[StringName]:
	return [&"BeehaveNode"]


func can_send_message(blackboard: Blackboard) -> bool:
	return blackboard.get_value("can_send_message", false)


func _safe_tick(actor: Node, blackboard: Blackboard) -> int:
	var response = tick(actor, blackboard)
	if not response is int:
		push_error("All tick methods must return an int, got %s" % response)
		return FAILURE
	return response
