## Random action node that changes its state over time.
##
## Action node that returns a random status, depending on the action
## [member weights]. Changes its status every [member reset_duration_msec]
## milliseconds.
@tool
class_name RandomAction extends ActionLeaf


## How often this action changes its return status, in milliseconds.
@export var reset_duration_msec: = 1000


var last_step = 0
var action = 0

## Array of 3 floats signifying the weights of SUCCESS, FAILURE and RUNNING
## statuses respectively.
var weights = [3., 3., 1.]


func _get_random_action():
	var sum = 0.
	for w in weights:
		sum += w
	var rnd = randf_range(0, sum)
	for i in weights.size():
		if rnd <= weights[i]:
			return i
		rnd -= weights[i]
	return weights.size() - 1


func tick(actor: Node, blackboard: Blackboard) -> int:
	var step = Time.get_ticks_msec() / reset_duration_msec
	if step != last_step:
		action = _get_random_action()
		last_step = step
	return action
