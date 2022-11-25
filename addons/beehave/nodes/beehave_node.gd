## A node in the behaviour tree. Every node must return `SUCCESS`, `FAILURE` or
## `RUNNING` when ticked.
class_name BeehaveNode extends BeehaveTree
@icon("../icons/action.svg")

enum { SUCCESS, FAILURE, RUNNING }

func tick(actor, blackboard):
	pass
