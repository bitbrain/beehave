## An inverter will return `FAILURE` in case it's child returns a `SUCCESS` status
## code or `SUCCESS` in case its child returns a `FAILURE` status code.
@tool
@icon("../../icons/inverter.svg")
class_name InverterDecorator extends Decorator

func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		if response == SUCCESS:
			return FAILURE
		if response == FAILURE:
			return SUCCESS

		if c is ActionLeaf:
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))
			
		return RUNNING
	
	# Decorators must have a child. This should be unreachable code.
	return FAILURE
