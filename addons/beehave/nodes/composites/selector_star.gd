## Selector Star nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`. This node will skip all previous child nodes that were
## executed prior, in case one of the children is currently in `RUNNING` state.
@tool
class_name SelectorStarComposite extends Composite
@icon("../../icons/selector_reactive.svg")

var last_execution_index = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c.get_index() < last_execution_index:
			continue
		
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c)
			blackboard.set_value("last_condition_status", response)

		if response != FAILURE:
			if response == SUCCESS:
				last_execution_index = 0
			else: # RUNNING
				running_child = c
			return response
		else:
			last_execution_index += 1

	last_execution_index = 0
	return FAILURE
