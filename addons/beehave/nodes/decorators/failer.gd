## A Failer node will always return a `FAILURE` status code.
@tool
class_name AlwaysFailDecorator extends Decorator
@icon("../../icons/failer.svg")


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		if response == RUNNING:
			return RUNNING
	return FAILURE
