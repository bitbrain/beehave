## The limiter will execute its child `x` amount of times. When the number of
## maximum ticks is reached, it will return a `FAILURE` status code.
@tool
@icon("../../icons/limiter.svg")
class_name LimiterDecorator extends Decorator

@onready var cache_key = 'limiter_%s' % self.get_instance_id()

@export var max_count : float = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_count = blackboard.get_value(cache_key, str(actor.get_instance_id()))

	if current_count == null:
		current_count = 0

	if current_count <= max_count:
		blackboard.set_value(cache_key, current_count + 1, str(actor.get_instance_id()))
		return self.get_child(0).tick(actor, blackboard)
	else:
		return FAILURE
