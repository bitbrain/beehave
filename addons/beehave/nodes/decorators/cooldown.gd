@tool
@icon("../../icons/cooldown.svg")
extends Decorator
class_name CooldownDecorator

## The Cooldown Decorator will return 'FAILURE' for a set amount of time
## after executing its child.
## The timer resets the next time its child is executed and it is not `RUNNING`
## or when the node is interrupted (such as when the behavior tree changes branches).

## The wait time in seconds
@export var wait_time := 0.0

@onready var cache_key = "cooldown_%s" % self.get_instance_id()


func tick(actor: Node, blackboard: Blackboard) -> int:
	var c: BeehaveNode = get_child(0)
	var remaining_time: float = blackboard.get_value(cache_key, 0.0, str(actor.get_instance_id()))
	var response: int

	if c != running_child:
		c.before_run(actor, blackboard)

	if remaining_time > 0:
		response = FAILURE

		remaining_time -= get_physics_process_delta_time()
		blackboard.set_value(cache_key, remaining_time, str(actor.get_instance_id()))
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(self.get_instance_id(), response, blackboard.get_debug_data())
	else:
		response = c._safe_tick(actor, blackboard)

		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response, blackboard.get_debug_data())

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		if response == RUNNING:
			running_child = c
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, str(actor.get_instance_id()))
		else:
			c.after_run(actor, blackboard)
			blackboard.set_value(cache_key, wait_time, str(actor.get_instance_id()))

	return response

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	# Reset the cooldown when the branch changes
	blackboard.set_value(cache_key, 0.0, str(actor.get_instance_id()))
	super.interrupt(actor, blackboard)
