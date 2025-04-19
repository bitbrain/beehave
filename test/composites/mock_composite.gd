class_name MockComposite
extends Composite

@export_enum("Success", "Failure", "Running") var final_result: int = 0

signal interrupted(actor, blackboard)

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	interrupted.emit(actor, blackboard)

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	return final_result
