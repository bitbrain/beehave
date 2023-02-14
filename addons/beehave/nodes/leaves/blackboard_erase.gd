@tool
class_name BlackboardEraseAction extends ActionLeaf


@export var key: String = ""


func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.erase_value(key)
	return SUCCESS

