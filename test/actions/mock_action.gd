class_name MockAction
extends BeehaveAction

@export_enum("Success", "Failure") var final_result: int = 0
@export var running_frame_count: int = 0

signal started_running(actor, blackboard)
signal stopped_running(actor, blackboard)
signal interrupted(actor, blackboard)

var tick_count: int = 0


func before_run(context: BeehaveContext) -> void:
	tick_count = 0
	started_running.emit(context.get_actor(), context.get_blackboard())


func tick(_context: BeehaveContext) -> int:
	if tick_count < running_frame_count:
		tick_count += 1
		return RUNNING
	else:
		return final_result


func interrupt(context: BeehaveContext) -> void:
	interrupted.emit(context.get_actor(), context.get_blackboard())


func after_run(context: BeehaveContext) -> void:
	tick_count = 0
	stopped_running.emit(context.get_actor(), context.get_blackboard())
