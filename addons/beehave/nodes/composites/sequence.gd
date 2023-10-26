@tool
@icon("../../icons/sequence.svg")
class_name SequenceComposite extends Composite

## Sequence nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE` and restart.
## In case a child returns `RUNNING` this node will tick again.

var successful_index: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():

		if c.get_index() < successful_index:
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
				successful_index += 1
				c.after_run(actor, blackboard)
			FAILURE:
				_cleanup_running_task(c, actor, blackboard)
				# Interrupt any child that was RUNNING before.
				interrupt(actor, blackboard)
				c.after_run(actor, blackboard)
				return FAILURE
			RUNNING:
				if c != running_child:
					if running_child != null:
						running_child.interrupt(actor, blackboard)
					running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	_reset()
	return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	_reset()
	super(actor, blackboard)


func _reset() -> void:
	successful_index = 0


## Changes `running_action` and `running_child` after the node finishes executing.
func _cleanup_running_task(finished_action: Node, actor: Node, blackboard: Blackboard):
	var blackboard_name = str(actor.get_instance_id())
	if finished_action == running_child:
		running_child = null
		if finished_action == blackboard.get_value("running_action", null, blackboard_name):
			blackboard.set_value("running_action", null, blackboard_name)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SequenceComposite")
	return classes
