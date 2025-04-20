@tool
@icon("../../icons/selector.svg")
class_name SelectorComposite extends Composite


# A Selector runs its children in order until one succeeds or is running.
# On failure, skips already-processed children across ticks.


var last_execution_index: int = 0
var previous_success_or_running_index: int = -1
var ready_to_interrupt_all: bool = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	var children = get_children()
	var children_count = children.size()
	var processed_count = 0
	
	for i in range(children.size()):
		var child = children[i]
		if child.get_index() < last_execution_index:
			processed_count += 1
			continue

		if child != running_child:
			child.before_run(actor, blackboard)

		var response = child._safe_tick(actor, blackboard)
		processed_count += 1
		
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(child.get_instance_id(), response, blackboard.get_debug_data())

		if child is ConditionLeaf:
			var id = str(actor.get_instance_id())
			blackboard.set_value("last_condition", child, id)
			blackboard.set_value("last_condition_status", response, id)

		match response:
			SUCCESS:
				if running_child != null:
					if running_child != child:
						running_child.interrupt(actor, blackboard)
					_cleanup_running(running_child, actor, blackboard)
				child.after_run(actor, blackboard)
				_interrupt_children(actor, blackboard, i, previous_success_or_running_index)
				previous_success_or_running_index = i
				ready_to_interrupt_all = false
				return SUCCESS

			FAILURE:
				if running_child != null and running_child == child:
					_cleanup_running(running_child, actor, blackboard)
				child.after_run(actor, blackboard)
				last_execution_index = max(last_execution_index, child.get_index() + 1)

			RUNNING:
				if child != running_child:
					if running_child != null:
						running_child.interrupt(actor, blackboard)
					running_child = child
				if child is ActionLeaf:
					blackboard.set_value("running_action", child, str(actor.get_instance_id()))
				_interrupt_children(actor, blackboard, i, previous_success_or_running_index)
				previous_success_or_running_index = i
				ready_to_interrupt_all = false
				return RUNNING

	# all children failed
	ready_to_interrupt_all = (processed_count == children_count)
	last_execution_index = 0
	return FAILURE


func after_run(actor: Node, blackboard: Blackboard) -> void:
	last_execution_index = 0
	super(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if ready_to_interrupt_all:
		# If all children failed, interrupt all children by using indices 0 and children.size()-1
		var children = get_children()
		if children.size() > 0:
			_interrupt_children(actor, blackboard, -1, children.size() - 1)
		ready_to_interrupt_all = false
	else:
		# Use the normal interrupt logic for partial processing
		_interrupt_children(actor, blackboard, last_execution_index, previous_success_or_running_index)
	if running_child != null:
		running_child.interrupt(actor, blackboard)
		_cleanup_running(running_child, actor, blackboard)
	last_execution_index = 0
	previous_success_or_running_index = -1
	super(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes = super()
	classes.push_back(&"SelectorComposite")
	return classes
