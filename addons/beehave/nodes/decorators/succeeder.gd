## A succeeder node will always return a `SUCCESS` status code.
@tool
class_name AlwaysSucceedDecorator extends Decorator
@icon("../../icons/succeeder.svg")


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		if response == RUNNING:
			return RUNNING
	return SUCCESS
