extends BeehaveTree

class_name BeehaveNode, "../icons/action.svg"

enum { SUCCESS, FAILURE, RUNNING }

signal tick_start(node)
signal tick_end(node, status)

func tick(actor, blackboard):
	emit_signal("tick_start", self)
	var result = self._tick(actor, blackboard)
	emit_signal("tick_end", self, result)
	return result

func _tick(actor, blackboard):
	pass
