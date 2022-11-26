## Conditions are leaf nodes that either return SUCCESS or FAILURE depending on
## a single simple condition. They should never return `RUNNING`.
extends Leaf

class_name ConditionLeaf
@icon("../../icons/condition.svg")
