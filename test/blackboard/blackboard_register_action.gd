extends ActionLeaf

var blackboard


func tick(actor: Node, blackboard: Blackboard) -> int:
	self.blackboard = blackboard
	return SUCCESS
