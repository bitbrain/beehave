@tool
@icon("../../icons/sequence_random.svg")
class_name SequenceRandomComposite extends RandomizedComposite

## This node will attempt to execute all of its children just like a
## [code]SequenceStar[/code] would, with the exception that the children
## will be executed in a random order.

# Emitted whenever the children are shuffled.
signal reset(new_order: Array[Node])

## Whether the sequence should start where it left off after a previous failure.
@export var resume_on_failure: bool = false
## Whether the sequence should start where it left off after a previous interruption.
@export var resume_on_interrupt: bool = false

## A shuffled list of the children that will be executed in reverse order.
var _children_bag: Array[Node] = []
var c: Node


func _ready() -> void:
	super()
	if random_seed == 0:
		randomize()


func tick(actor: Node, blackboard: Blackboard) -> int:
	if _children_bag.is_empty():
		_reset()

	# We need to traverse the array in reverse since we will be manipulating it.
	for i in _get_reversed_indexes():
		c = _children_bag[i]

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
				_children_bag.erase(c)
				c.after_run(actor, blackboard)
			FAILURE:
				_children_bag.erase(c)
				# Interrupt any child that was RUNNING before
				# but do not reset!
				super.interrupt(actor, blackboard)
				c.after_run(actor, blackboard)
				return FAILURE
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return SUCCESS


func after_run(actor: Node, blackboard: Blackboard) -> void:
	if not resume_on_failure:
		_reset()
	super(actor, blackboard)


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if not resume_on_interrupt:
		if running_child != null:
			running_child.interrupt(actor, blackboard)
			running_child = null
		_reset()
	super(actor, blackboard)


func _get_reversed_indexes() -> Array[int]:
	var reversed: Array[int]
	reversed.assign(range(_children_bag.size()))
	reversed.reverse()
	return reversed


func _reset() -> void:
	var new_order: Array[Node] = get_shuffled_children()
	_children_bag = new_order.duplicate()
	_children_bag.reverse()  # It needs to run the children in reverse order.
	reset.emit(new_order)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SequenceRandomComposite")
	return classes
