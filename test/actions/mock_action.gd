class_name MockAction
extends ActionLeaf

@export_enum("Success", "Failure") var final_result: int = 0
@export var running_frame_count: int = 0

signal entered(actor, blackboard)
signal exited(actor, blackboard)
signal interrupted(actor, blackboard)

var tick_count: int = 0


func enter(actor: Node, blackboard: Blackboard) -> void:
	tick_count = 0
	entered.emit(actor, blackboard)


func tick(actor: Node, blackboard: Blackboard) -> int:
	if tick_count < running_frame_count:
		tick_count += 1
		return RUNNING
	else:
		return final_result


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	interrupted.emit(actor, blackboard)


func exit(actor: Node, blackboard: Blackboard) -> void:
	tick_count = 0
	exited.emit(actor, blackboard)
