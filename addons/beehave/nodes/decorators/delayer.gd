@tool
@icon("../../icons/delayer.svg")
extends Decorator
class_name DelayDecorator

## The Delay Decorator will return 'RUNNING' for a set amount of time
## before executing its child.
## The timer resets the next time that a child is not `RUNNING`

## The wait time in seconds
@export_range(0.001, 4096.0, 0.001) var time: float = 1.0
var timer: SceneTreeTimer = null

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	
	if c != running_child:
		c.before_run(actor, blackboard)
	
	if timer == null:
		timer = get_tree().create_timer(time)
	
	var response
	
	if timer.time_left > 0:
		response = RUNNING
		
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(self.get_instance_id(), response)
	else:
		response = c.tick(actor, blackboard)
	
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))
	
		if response == RUNNING and c is ActionLeaf:
			running_child = c
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))
	
	if response != RUNNING:
		timer = null
	
	return response

