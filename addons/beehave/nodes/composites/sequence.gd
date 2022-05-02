extends Composite

class_name SequenceComposite, "../../icons/sequencer.svg"

func tick(actor, blackboard):
	for c in get_children():
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set("last_condition", c)
			blackboard.set("last_condition_status", response)

		if response != SUCCESS:
			if c is ActionLeaf and response == RUNNING:
				blackboard.set("running_action", c)
			return response

	return SUCCESS
