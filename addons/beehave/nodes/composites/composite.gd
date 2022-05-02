extends BehaviorTreeNode

class_name Composite, "../../icons/category_composite.svg"


func _ready():
	if self.get_child_count() < 1:
		print("BehaviorTree Error: Composite %s should have at least one child" % self.name)


# DO NOT CHANGE THIS SCRIPT. GO TO INSPECTOR SCRIPT -> EXTEND SCRIPT
