@tool
@icon("../../icons/sequence.svg")
class_name SequenceComposite extends Composite

## Sequence nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE` and restart.
## In case a child returns `RUNNING` this node will tick again.

var successful_index: int = 0
# Track where we last failed – so we detect a backward jump
var previous_failure_or_running_index: int = -1


func tick(actor: Node, blackboard: Blackboard) -> int:
	var children = get_children()
	for i in range(children.size()):
		var c = children[i]
		if c.get_index() < successful_index:
			continue

		if c != running_child:
			c.before_run(actor, blackboard)

		var response: int = c._safe_tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response, blackboard.get_debug_data())

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				if running_child != null and running_child == c:
					# do not interrupt as this child finishes running!
					_cleanup_running(running_child, actor, blackboard)
				successful_index += 1
				c.after_run(actor, blackboard)
			FAILURE:
				if running_child != null:
					running_child.interrupt(actor, blackboard)
					_cleanup_running(running_child, actor, blackboard)
				
				_interrupt_children(actor, blackboard, i, previous_failure_or_running_index)
						
				# remember where we failed for next tick
				previous_failure_or_running_index = c.get_index()
				successful_index = 0
				
				# Interrupt any child that was RUNNING before
				# but do not reset!
				if running_child != null:
					running_child.interrupt(actor, blackboard)
					running_child = null
					
				c.after_run(actor, blackboard)
				return FAILURE
			RUNNING:
				if running_child != null and c != running_child:
					running_child.interrupt(actor, blackboard)
					_cleanup_running(running_child, actor, blackboard)
				if c != running_child:
					running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				_interrupt_children(actor, blackboard, i, previous_failure_or_running_index)
				previous_failure_or_running_index = i
				return RUNNING

	successful_index = 0
	return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	_interrupt_children(actor, blackboard, successful_index - 1, previous_failure_or_running_index)
	if running_child != null:
		running_child.interrupt(actor, blackboard)
		_cleanup_running(running_child, actor, blackboard)
	_reset()
	super(actor, blackboard)


func _reset() -> void:
	successful_index = 0
	previous_failure_or_running_index = -1

func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SequenceComposite")
	return classes
