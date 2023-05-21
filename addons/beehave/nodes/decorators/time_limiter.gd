## The Time Limit Decorator will give its child a set amount of time to finish
## before interrupting it and return a `FAILURE` status code. The timer is reset
## every time before the node runs.
@tool
@icon("../../icons/limiter.svg")
class_name TimeLimiterDecorator extends Decorator

@export var wait_time: = 0.0

var time_left: = 0.0

@onready var child: BeehaveNode = get_child(0)


func tick(actor: Node, blackboard: Blackboard) -> int:
	if time_left < wait_time:
		time_left += get_physics_process_delta_time()
		var response = child.tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(child.get_instance_id(), response)
		
		if child is ConditionLeaf:
			blackboard.set_value("last_condition", child, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))
		
		if response == RUNNING:
			running_child = child
			if child is ActionLeaf:
				blackboard.set_value("running_action", child, str(actor.get_instance_id()))
		
		return response
	else:
		child.after_run(actor, blackboard)
		interrupt(actor, blackboard)
		return FAILURE


func before_run(actor: Node, blackboard: Blackboard) -> void:
	time_left = 0.0
	child.before_run(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"TimeLimiterDecorator")
	return classes
