## The Cooldown Decorator will return 'FAILURE' for a set amount of time
## after executing its child.
## The timer resets the next time its child is executed and it is not `RUNNING`
## or when the node is interrupted (such as when the behavior tree changes branches).
@tool
@icon("../../icons/cooldown.svg")
extends Decorator
class_name CooldownDecorator

## The wait time in seconds
@export var wait_time := 0.0

@onready var cache_key = "cooldown_%s" % self.get_instance_id()


func tick(actor: Node, blackboard: Blackboard) -> int:
	var c: BeehaveNode = get_child(0)
	var actor_id := str(actor.get_instance_id())
	var end_time: float = blackboard.get_value(cache_key, 0.0, actor_id)
	var current_time = Time.get_ticks_msec()
	var response: int

	if current_time < end_time:
		response = FAILURE

		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(self.get_instance_id(), response, blackboard.get_debug_data())
	else:
		if c != running_child:
			c.before_run(actor, blackboard)

		response = c._safe_tick(actor, blackboard)

		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response, blackboard.get_debug_data())

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, actor_id)
			blackboard.set_value("last_condition_status", response, actor_id)

		if response == RUNNING:
			running_child = c
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, actor_id)
		else:
			end_time = Time.get_ticks_msec() + wait_time * 1000
			c.after_run(actor, blackboard)
			blackboard.set_value(cache_key, end_time, actor_id)

	return response

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	# Reset the cooldown when the branch changes
	blackboard.set_value(cache_key, 0.0, str(actor.get_instance_id()))
	super.interrupt(actor, blackboard)