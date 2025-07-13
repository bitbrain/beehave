## Actions are leaf nodes that define a task to be performed by an actor.
## Their execution can be long running, potentially being called across multiple
## frame executions. In this case, the node should return `RUNNING` until the
## action is completed.
@tool
@icon("../../icons/action.svg")
class_name ActionLeaf extends Leaf


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"ActionLeaf")
	return classes
