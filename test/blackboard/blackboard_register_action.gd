extends ActionLeaf


var blackboard


func tick(actor, blackboard: Blackboard):
	self.blackboard = blackboard
	return SUCCESS

