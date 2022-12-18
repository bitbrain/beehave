## Actions are leaf nodes that define a task to be performed by an actor.
## Their execution can be long running, potentially being called across multiple
## frame executions. In this case, the node should return `RUNNING` until the
## action is completed.
@tool
class_name ActionLeaf extends Leaf
@icon("../../icons/action.svg")
