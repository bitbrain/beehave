## Sequence Star nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE`. This node will skip all previous child nodes that succeeded
## prior, in case one of the children is currently in `RUNNING` state
@tool
class_name SequenceStarComposite extends Composite
@icon("../../icons/sequence_reactive.svg")

var successful_index = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c.get_index() < successful_index:
			continue
		
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c)
			blackboard.set_value("last_condition_status", response)

		if response != SUCCESS:
			if response == FAILURE:
				successful_index = 0
			else: # RUNNING
				running_child = c
			return response
		else:
			successful_index += 1
			
	if successful_index == get_child_count():
		successful_index = 0
		return SUCCESS
	else:
		successful_index = 0
		return FAILURE
