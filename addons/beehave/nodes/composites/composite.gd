## A Composite node controls the flow of execution of its children in a specific manner.
extends BeehaveNode

class_name Composite
@icon("../../icons/category_composite.svg")


var running_child: BeehaveNode = null


func _ready():
	if self.get_child_count() < 1:
		push_error("BehaviorTree Error: Composite %s should have at least one child (NodePath: %s)" % [self.name, self.get_path()])


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	if running_child != null:
		running_child.interrupt(actor, blackboard)
		running_child = null
