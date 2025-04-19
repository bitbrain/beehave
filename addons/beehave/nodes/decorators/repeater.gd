## The repeater will execute its child until it returns `SUCCESS` a certain amount of times.
## When the number of maximum ticks is reached, it will return a `SUCCESS` status code.
## If the child returns `FAILURE`, the repeater will return `FAILURE` immediately.
## The counter resets when the node is interrupted (such as when the behavior tree changes branches).
@tool
@icon("../../icons/repeater.svg")
class_name RepeaterDecorator extends Decorator

@export var repetitions: int = 1
var current_count: int = 0


func before_run(actor: Node, blackboard: Blackboard):
	current_count = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var child: BeehaveNode = get_child(0)

	if current_count < repetitions:
		if running_child == null:
			child.before_run(actor, blackboard)

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
			return RUNNING

		current_count += 1
		child.after_run(actor, blackboard)

		if running_child != null:
			running_child = null

		if response == FAILURE:
			return FAILURE

		if current_count >= repetitions:
			return SUCCESS

		return RUNNING
	else:
		return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	# Reset the internal counter when the node is interrupted
	current_count = 0
		
	super(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"LimiterDecorator")
	return classes
