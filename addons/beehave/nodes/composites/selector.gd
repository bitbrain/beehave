## Selector nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`. This node will attempt to process all its children every
## single tick, even if one of them is currently `RUNNING` already.
@tool
class_name SelectorComposite extends Composite
@icon("../../icons/selector.svg")

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c)
			blackboard.set_value("last_condition_status", response)

		if response != FAILURE:
			if response == SUCCESS:
				# Interrupt any child that was RUNNING before.
				interrupt(actor, blackboard)
			else: # RUNNING
				running_child = c
			return response

	return FAILURE
