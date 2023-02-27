## Selector nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`. This node will attempt to process all its children every
## single tick, even if one of them is currently `RUNNING` already.
@tool
@icon("../../icons/selector.svg")
class_name SelectorComposite extends Composite

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				# Interrupt any child that was RUNNING before.
				interrupt(actor, blackboard)
				c.after_run(actor, blackboard)
				return SUCCESS
			FAILURE:
				c.after_run(actor, blackboard)
			RUNNING:
				if c != running_child:
					interrupt(actor, blackboard)
					running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return FAILURE


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SelectorComposite")
	return classes
