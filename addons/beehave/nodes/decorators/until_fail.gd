@tool
@icon("../../icons/until_fail.svg")
class_name UntilFailDecorator 
extends Decorator

## The UntilFail Decorator will return `RUNNING` if its child returns
## `SUCCESS` or `RUNNING` or it will return `SUCCESS` if its child returns
## `FAILURE`

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	
	if c != running_child:
		c.before_run(actor, blackboard)
	
	var response = c.tick(actor, blackboard)
	if can_send_message(blackboard):
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

	if c is ConditionLeaf:
		blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
		blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))
	
	if response == RUNNING:
		running_child = c
		if c is ActionLeaf:
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))
		return RUNNING
	if response == SUCCESS:
		return RUNNING
	
	return SUCCESS

