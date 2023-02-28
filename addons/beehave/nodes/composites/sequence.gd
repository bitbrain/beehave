## Sequence nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE`. This node will attempt to process all its children every
## single tick, even if one of them is currently `RUNNING` already.
@tool
@icon("../../icons/sequence.svg")
class_name SequenceComposite extends Composite


var successful_index: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():

		if c.get_index() < successful_index:
			continue
		
		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				successful_index += 1
				c.after_run(actor, blackboard)
			FAILURE:
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


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SequenceComposite")
	return classes
