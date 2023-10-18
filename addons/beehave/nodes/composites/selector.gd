@tool
@icon("../../icons/selector.svg")
class_name SelectorComposite extends Composite

## Selector nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`.
## If a child returns `RUNNING` it will tick again.

var last_execution_index: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c.get_index() < last_execution_index:
			continue

		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				_cleanup_running_task(c, actor, blackboard)
				c.after_run(actor, blackboard)
				return SUCCESS
			FAILURE:
				_cleanup_running_task(c, actor, blackboard)
				last_execution_index += 1
				c.after_run(actor, blackboard)
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return FAILURE


func after_run(actor: Node, blackboard: Blackboard) -> void:
	last_execution_index = 0
	super(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	last_execution_index = 0
	super(actor, blackboard)


## Changes `running_action` and `running_child` after the node finishes executing.
func _cleanup_running_task(finished_action: Node, actor: Node, blackboard: Blackboard):
	var blackboard_name = str(actor.get_instance_id())
	if finished_action == running_child:
		running_child = null
		if finished_action == blackboard.get_value("running_action", null, blackboard_name):
			blackboard.set_value("running_action", null, blackboard_name)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SelectorComposite")
	return classes
