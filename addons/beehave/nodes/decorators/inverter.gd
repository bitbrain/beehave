## An inverter will return `FAILURE` in case it's child returns a `SUCCESS` status
## code or `SUCCESS` in case its child returns a `FAILURE` status code.
@tool
@icon("../../icons/inverter.svg")
class_name InverterDecorator extends Decorator

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)

		if response == SUCCESS:
			return FAILURE
		if response == FAILURE:
			return SUCCESS

		if c is Leaf and response == RUNNING:
			blackboard.set_value("running_action", c)
		return RUNNING
	
	# Decorators must have a child. This should be unreachable code.
	return FAILURE
