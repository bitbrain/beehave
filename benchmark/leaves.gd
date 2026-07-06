## Constant-time leaves used by benchmark suites to measure pure framework
## overhead without any gameplay logic attached.
extends RefCounted


class Action extends ActionLeaf:
	var status: int = SUCCESS

	func tick(_actor: Node, _blackboard: Blackboard) -> int:
		return status


class Condition extends ConditionLeaf:
	var status: int = SUCCESS

	func tick(_actor: Node, _blackboard: Blackboard) -> int:
		return status
