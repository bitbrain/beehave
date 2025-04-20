@tool
@icon("../../icons/category_composite.svg")
class_name Composite extends BeehaveNode

## A Composite node controls the flow of execution of its children in a specific manner.

var running_child: BeehaveNode = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()

	if get_children().filter(func(x): return x is BeehaveNode).size() < 2:
		warnings.append(
			"Any composite node should have at least two children. Otherwise it is not useful."
		)

	return warnings


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if running_child != null:
		running_child.interrupt(actor, blackboard)
		running_child = null
	super.interrupt(actor, blackboard)


func after_run(actor: Node, blackboard: Blackboard) -> void:
	running_child = null


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"Composite")
	return classes
	
	
func _cleanup_running(child: Node, actor: Node, blackboard: Blackboard) -> void:
	if child == running_child:
		running_child = null
		var id = str(actor.get_instance_id())
		if child == blackboard.get_value("running_action", null, id):
			blackboard.set_value("running_action", null, id)
	
	
func _interrupt_children(actor: Node, blackboard: Blackboard, from_index: int, last_index: int) -> void:
	var children = get_children()
	var start = from_index + 1
	var end = 0
	if last_index > from_index:
		end = last_index + 1
	else:
		return

	for j in range(start, end):
		var stale = children[j]
		stale.interrupt(actor, blackboard)
