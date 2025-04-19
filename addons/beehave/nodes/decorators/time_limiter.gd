@tool
@icon("../../icons/limiter.svg")
class_name TimeLimiterDecorator extends Decorator

## The Time Limit Decorator will give its `RUNNING` child a set amount of time to finish
## before interrupting it and return a `FAILURE` status code.
## The timer resets the next time that a child is not `RUNNING`
## or when the node is interrupted (such as when the behavior tree changes branches).

@export var wait_time := 0.0

@onready var cache_key: String = "time_limiter_%s" % self.get_instance_id()


func tick(actor: Node, blackboard: Blackboard) -> int:
	if not get_child_count() == 1:
		return FAILURE

	var child: BeehaveNode = self.get_child(0)
	var time_left: float = blackboard.get_value(cache_key, 0.0, str(actor.get_instance_id()))

	if time_left < wait_time:
		time_left += get_physics_process_delta_time()
		blackboard.set_value(cache_key, time_left, str(actor.get_instance_id()))
		var response: int = child.tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(child.get_instance_id(), response, blackboard.get_debug_data())

		if child is ConditionLeaf:
			blackboard.set_value("last_condition", child, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		if response == RUNNING:
			running_child = child
			if child is ActionLeaf:
				blackboard.set_value("running_action", child, str(actor.get_instance_id()))
		else:
			child.after_run(actor, blackboard)
		return response
	else:
		interrupt(actor, blackboard)
		child.after_run(actor, blackboard)
		return FAILURE


func before_run(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value(cache_key, 0.0, str(actor.get_instance_id()))
	if get_child_count() > 0:
		get_child(0).before_run(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	# Reset the timer when the node is interrupted
	blackboard.set_value(cache_key, 0.0, str(actor.get_instance_id()))
		
	super(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"TimeLimiterDecorator")
	return classes


func _get_configuration_warnings() -> PackedStringArray:
	if not get_child_count() == 1:
		return ["Requires exactly one child node"]
	return []
