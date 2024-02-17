class_name CountUpAction extends BeehaveAction

@export var key = "custom_value"

var count = 0
var status = SUCCESS

func tick(context: BeehaveContext) -> int:
	count += 1
	context.get_blackboard().set_value(key, count)
	return status


func interrupt(context: BeehaveContext) -> void:
	count = 0
	context.get_blackboard().set_value(key, count)
	status = FAILURE
