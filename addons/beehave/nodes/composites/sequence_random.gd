## This node will attempt to execute all of its children just like a 
## [code]SequenceStar[/code] would, with the exception that the children 
## will be executed in a random order.
@tool
class_name SequenceRandomComposite extends Composite
@icon("../../icons/sequence_random.svg")


## Whether the sequence should start where it left off after a previous failure.
@export var resume_on_failure: bool = false
## Whether the sequence should start where it left off after a previous interruption.
@export var resume_on_interrupt: bool = false

## A shuffled list of the children that will be executed in reverse order. 
var _children_bag: Array[Node] = []
var c: Node


func tick(actor: Node, blackboard: Blackboard) -> int:
	if _children_bag.is_empty():
		_reset()
	
	# We need to traverse the array in reverse since we will be manipulating it.
	for i in _get_reversed_indexes():
		c = _children_bag[i]
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c)
			blackboard.set_value("last_condition_status", response)
		
		if response == RUNNING:
			running_child = c
		else:
			_children_bag.erase(c)
		
		if response != SUCCESS:
			if not resume_on_failure and response == FAILURE:
				_reset()
			return response

	return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if not resume_on_interrupt:
		_reset()
	super(actor, blackboard)


func _get_reversed_indexes() -> Array[int]:
	var reversed = range(_children_bag.size())
	reversed.reverse()
	return reversed


## Generates a new shuffled list of the children.
func _reset() -> void:
	_children_bag = get_children().duplicate()
	_children_bag.shuffle()
