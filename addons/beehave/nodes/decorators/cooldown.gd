@tool
@icon("../../icons/cooldown.svg")
extends Decorator
class_name CooldownDecorator

## The Cooldown Decorator will return 'FAILURE' for a set amount of time
## after executing its child.
## The timer resets the next time its child is executed and it is not `RUNNING`

## The wait time in seconds
@export var wait_time: = 0.0

@onready var cache_key = 'cooldown_%s' % self.get_instance_id()


func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	var remaining_time = blackboard.get_value(cache_key, 0.0, str(actor.get_instance_id()))
	var response
	
	if c != running_child:
		c.before_run(actor, blackboard)
	
	if remaining_time > 0:
		response = FAILURE
		
		remaining_time -= get_physics_process_delta_time()
		blackboard.set_value(cache_key, remaining_time, str(actor.get_instance_id()))
		
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
			blackboard.set_value(cache_key, wait_time, str(actor.get_instance_id()))
	
	return response


