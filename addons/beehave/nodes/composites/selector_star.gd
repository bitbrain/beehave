## Selector Star nodes will attempt to execute each of its children until one of
## them return `SUCCESS`. If all children return `FAILURE`, this node will also
## return `FAILURE`. This node will skip all previous child nodes that were
## executed prior, in case one of the children is currently in `RUNNING` state.
@tool
@icon("../../icons/selector_reactive.svg")
class_name SelectorStarComposite extends Composite

var last_execution_index: int = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	for c in get_children():
		if c.get_index() < last_execution_index:
			continue
		
		if c != running_child:
			c.enter(actor, blackboard)
		
		var response = c.tick(actor, blackboard)
		
		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				c.exit(actor, blackboard)
				return SUCCESS
			FAILURE:
				last_execution_index += 1
				c.exit(actor, blackboard)
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return FAILURE


func exit(actor: Node, blackboard: Blackboard) -> void:
	last_execution_index = 0


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	exit(actor, blackboard)
	super(actor, blackboard)
