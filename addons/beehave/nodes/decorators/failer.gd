## A Failer node will always return a `FAILURE` status code.
@tool
@icon("../../icons/failer.svg")
class_name AlwaysFailDecorator extends Decorator


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		if response == RUNNING:
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, str(actor.get_instance_id()))
			return RUNNING
	return FAILURE
