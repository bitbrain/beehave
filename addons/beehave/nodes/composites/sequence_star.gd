## Sequence Star nodes will attempt to execute all of its children and report
## `SUCCESS` in case all of the children report a `SUCCESS` status code.
## If at least one child reports a `FAILURE` status code, this node will also
## return `FAILURE`. This node will skip all previous child nodes that succeeded
## prior, in case one of the children is currently in `RUNNING` state
@tool
@icon("../../icons/sequence_reactive.svg")
class_name SequenceStarComposite extends Composite


var successful_index: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c.get_index() < successful_index:
			continue

		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				successful_index += 1
				c.after_run(actor, blackboard)
			FAILURE:
				c.after_run(actor, blackboard)
				return FAILURE
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return SUCCESS


func after_run(actor: Node, blackboard: Blackboard) -> void:
	successful_index = 0


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	after_run(actor, blackboard)
	super(actor, blackboard)


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SequenceStarComposite")
	return classes
