@tool
@icon("../../icons/delayer.svg")
extends Decorator
class_name DelayDecorator

## The Delay Decorator will return 'RUNNING' for a set amount of time
## before executing its child.
## The timer resets when both it and its child are not `RUNNING`

## The wait time in seconds
@export var wait_time: = 0.0

@onready var cache_key = 'time_limiter_%s' % self.get_instance_id()

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	var total_time = blackboard.get_value(cache_key, 0.0, str(actor.get_instance_id()))
	var response
	
	if c != running_child:
		c.before_run(actor, blackboard)
	
	if total_time < wait_time:
		response = RUNNING
		
		total_time += get_physics_process_delta_time()
		blackboard.set_value(cache_key, total_time, str(actor.get_instance_id()))
		
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
			blackboard.set_value(cache_key, 0.0, str(actor.get_instance_id()))
	
	return response

