extends ActionLeaf

@export var modulate_color:Color

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.modulate = modulate_color
	return SUCCESS

