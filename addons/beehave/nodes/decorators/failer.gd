## A Failer node will always return a `FAILURE` status code.
extends Decorator

class_name AlwaysFailDecorator
@icon("../../icons/fail.svg")


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		if response == RUNNING:
			return RUNNING
	return FAILURE
