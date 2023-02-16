class_name MockAction
extends ActionLeaf

@export_enum("Success", "Failure") var final_result: int = 0
@export var running_frame_count: int = 0

signal started_running(actor, blackboard)
signal stopped_running(actor, blackboard)
signal interrupted(actor, blackboard)

var tick_count: int = 0


func before_run(actor: Node, blackboard: Blackboard) -> void:
	tick_count = 0
	started_running.emit(actor, blackboard)


func tick(actor: Node, blackboard: Blackboard) -> int:
	if tick_count < running_frame_count:
		tick_count += 1
		return RUNNING
	else:
		return final_result


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	interrupted.emit(actor, blackboard)


func after_run(actor: Node, blackboard: Blackboard) -> void:
	tick_count = 0
	stopped_running.emit(actor, blackboard)
