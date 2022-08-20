extends BeehaveNode

class_name Decorator, "../../icons/category_decorator.svg"


func _ready():
	if self.get_child_count() != 1:
		push_error("Beehave Error: Decorator %s (%s) should have only one child" % [self.name, self.get_path])
