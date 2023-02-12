## A Failer node will always return a `FAILURE` status code.
@tool
@icon("../../icons/failer.svg")
class_name AlwaysFailDecorator extends Decorator


func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	
	if c != running_child:
		c.enter(actor, blackboard)

	var response = c.tick(actor, blackboard)

	if c is ConditionLeaf:
		blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
		blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

	if response == RUNNING:
		running_child = c
		if c is ActionLeaf:
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))
		return RUNNING
	else:
		c.exit(actor, blackboard)
		return FAILURE
