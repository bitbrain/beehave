@tool
@icon("../../icons/selector_reactive.svg")
class_name SelectorReactiveComposite extends Composite

## Selector Reactive nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`.
## If a child returns `RUNNING` it will restart.



# Track where we last succeeded – so we detect true branch changes
var previous_success_or_running_index: int = -1
var ready_to_interrupt_all: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var children := get_children()
	var children_count = children.size()
	var processed_count = 0
	
	for i in range(children.size()):
		var c = children[i]

		if c != running_child:
			c.before_run(actor, blackboard)

		var response: int = c._safe_tick(actor, blackboard)
		processed_count += 1
		
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response, blackboard.get_debug_data())

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				# clean up the one that just succeeded
				if running_child != null:
					if running_child != c:
						running_child.interrupt(actor, blackboard)
					_cleanup_running(running_child, actor, blackboard)
				c.after_run(actor, blackboard)

				_interrupt_children(actor, blackboard, i, previous_success_or_running_index)
				previous_success_or_running_index = i
				ready_to_interrupt_all = false
				return SUCCESS

			FAILURE:
				c.after_run(actor, blackboard)

			RUNNING:
				if c != running_child:
					if running_child != null:
						running_child.interrupt(actor, blackboard)
					running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				_interrupt_children(actor, blackboard, i, previous_success_or_running_index)
				previous_success_or_running_index = i
				ready_to_interrupt_all = false
				return RUNNING

	# all failed → reset our success‐tracker
	ready_to_interrupt_all = (processed_count == children_count)
	return FAILURE


func after_run(actor: Node, blackboard: Blackboard) -> void:
	super(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if ready_to_interrupt_all:
		# If all children failed, interrupt all children
		var children = get_children()
		if children.size() > 0:
			_interrupt_children(actor, blackboard, -1, children.size() - 1)
		ready_to_interrupt_all = false
	else:
		# Use the normal interrupt logic for partial processing
		_interrupt_children(actor, blackboard, -1, previous_success_or_running_index)
	if running_child != null:
		running_child.interrupt(actor, blackboard)
		_cleanup_running(running_child, actor, blackboard)
	previous_success_or_running_index = -1
	super(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SelectorReactiveComposite")
	return classes
