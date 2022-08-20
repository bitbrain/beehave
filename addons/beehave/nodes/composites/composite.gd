extends BeehaveNode

class_name Composite, "../../icons/category_composite.svg"


func _ready():
	if self.get_child_count() < 1:
		push_error("BehaviorTree Error: Composite %s should have at least one child (NodePath: %s)" % [self.name, self.get_path()])
