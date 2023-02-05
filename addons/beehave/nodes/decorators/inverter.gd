## An inverter will return `FAILURE` in case it's child returns a `SUCCESS` status
## code or `SUCCESS` in case its child returns a `FAILURE` status code.
@tool
@icon("../../icons/inverter.svg")
class_name InverterDecorator extends Decorator


func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	
	if c != running_child:
		c.enter(actor, blackboard)

	var response = c.tick(actor, blackboard)

	if c is ConditionLeaf:
		blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
		blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

	match response:
		SUCCESS:
			c.exit(actor, blackboard)
			return FAILURE
		FAILURE:
			c.exit(actor, blackboard)
			return SUCCESS
		RUNNING:
			running_child = c
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, str(actor.get_instance_id()))
			return RUNNING
		_:
			push_error("This should be unreachable")
			return -1
