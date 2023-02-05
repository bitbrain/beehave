## Sequence nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE`. This node will attempt to process all its children every
## single tick, even if one of them is currently `RUNNING` already.
@tool
@icon("../../icons/sequence.svg")
class_name SequenceComposite extends Composite

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		
		if c != running_child:
			c.enter(actor, blackboard)
		
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))
		
		match response:
			SUCCESS:
				c.exit(actor, blackboard)
			FAILURE:
				# Interrupt any child that was RUNNING before.
				interrupt(actor, blackboard)
				c.exit(actor, blackboard)
				return FAILURE
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING
			
	return SUCCESS
