## This node will attempt to execute all of its children just like a 
## [code]SelectorStar[/code] would, with the exception that the children 
## will be executed in a random order.
@tool
@icon("../../icons/selector_random.svg")
class_name SelectorRandomComposite extends Composite

## Sets a predicable seed
@export var random_seed:int = 0:
	set(rs):
		random_seed = rs
		if random_seed != 0:
			seed(random_seed)
		else:
			randomize()


## A shuffled list of the children that will be executed in reverse order. 
var _children_bag: Array[Node] = []
var c: Node

func _ready() -> void:
	if random_seed == 0:
		randomize()

func tick(actor: Node, blackboard: Blackboard) -> int:
	if _children_bag.is_empty():
		_reset()
	
	# We need to traverse the array in reverse since we will be manipulating it.
	for i in _get_reversed_indexes():
		c = _children_bag[i]
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))
		
		if response == RUNNING:
			running_child = c
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, str(actor.get_instance_id()))
		else:
			_children_bag.erase(c)
		
		if response != FAILURE:
			if response == SUCCESS:
				_reset()
			return response

	return FAILURE


func interrupt(actor: Node, blackboard: Blackboard) -> void:
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
