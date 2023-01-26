extends ActionLeaf

var count = 0
var status = SUCCESS

func tick(actor: Node, blackboard: Blackboard) -> int:
	count += 1
	return status
