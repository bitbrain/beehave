extends Decorator

class_name LimiterDecorator, "../../icons/limiter.svg"

onready var cache_key = 'limiter_%s' % self.get_instance_id()

export (float) var max_count = 0

func tick(actor, blackboard):
	var current_count = blackboard.get(cache_key)

	if current_count == null:
		current_count = 0

	if current_count <= max_count:
		blackboard.set(cache_key, current_count + 1)
		return self.get_child(0).tick(actor, blackboard)
	else:
		return FAILED
