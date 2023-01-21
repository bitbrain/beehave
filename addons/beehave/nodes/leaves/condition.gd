## Conditions are leaf nodes that either return SUCCESS or FAILURE depending on
## a single simple condition. They should never return `RUNNING`.
@tool
@icon("../../icons/condition.svg")
class_name ConditionLeaf extends Leaf
