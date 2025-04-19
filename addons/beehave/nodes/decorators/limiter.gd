@tool
@icon("../../icons/limiter.svg")
class_name LimiterDecorator extends Decorator

## The limiter will execute its `RUNNING` child `x` amount of times. When the number of
## maximum ticks is reached, it will return a `FAILURE` status code.
## The count resets the next time that a child is not `RUNNING`
## or when the node is interrupted (such as when the behavior tree changes branches).

@onready var cache_key = "limiter_%s" % self.get_instance_id()

@export var max_count: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	if not get_child_count() == 1:
		return FAILURE

	var child: BeehaveNode = get_child(0)
	var current_count: int = blackboard.get_value(cache_key, 0, str(actor.get_instance_id()))

	if current_count < max_count:
		blackboard.set_value(cache_key, current_count + 1, str(actor.get_instance_id()))
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
			# If the child is no longer running, reset the counter for next time
			_reset_counter(actor, blackboard)
			child.after_run(actor, blackboard)

		return response
	else:
		interrupt(actor, blackboard)
		child.after_run(actor, blackboard)
		return FAILURE


func before_run(actor: Node, blackboard: Blackboard) -> void:
	# Initialize the counter to 0 when we first start running
	_reset_counter(actor, blackboard)
	if get_child_count() > 0:
		get_child(0).before_run(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	# The tree is changing branches, so the count should reset
	_reset_counter(actor, blackboard)
	
	# Call super, which may affect our blackboard values
	super(actor, blackboard)


# Resets the counter in the blackboard
func _reset_counter(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value(cache_key, 0, str(actor.get_instance_id()))


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"LimiterDecorator")
	return classes


func _get_configuration_warnings() -> PackedStringArray:
	if not get_child_count() == 1:
		return ["Requires exactly one child node"]
	return []
