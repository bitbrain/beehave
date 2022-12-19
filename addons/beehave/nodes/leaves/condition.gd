## Conditions are leaf nodes that either return SUCCESS or FAILURE depending on
## a single simple condition. They should never return `RUNNING`.
@tool
class_name ConditionLeaf extends Leaf
@icon("../../icons/condition.svg")
