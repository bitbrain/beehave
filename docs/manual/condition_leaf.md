# Condition Leaf

The Condition Leaf is a type of node in a behavior tree that checks for a specific condition to be true or false, such as *health_above_50* or *is_alive*. It is used to make decisions based on the outcome of a condition.

## Usage

A `ConditionLeaf` node may be used to create decision-making behaviors in a behavior tree. It evaluates a user defined condition and returns a status depending on the outcome of the evaluation. If the condition is `true`, the `ConditionLeaf` returns a `SUCCESS` status. If the condition is `false`, the `ConditionLeaf` returns a `FAILURE` status. The Condition Leaf can be used to check a wide range of conditions, such as the proximity of an enemy, the availability of a certain item, or the health of the player character.

## Return Type

The `ConditionLeaf` returns a status code, which indicates whether the condition is `true` or `false`. The status can be on one of the following values:

Value | Description 
-- | -- 
`SUCCESS` | Indicates that the condition is true
`FAILURE` | Indicates that the condition is false

## Example

Here is an example of how a `ConditionLeaf` might be used to check if the player character is within attack range of an enemy:

```gdscript
class_name IsPlayerWithinAttackRange extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_from_player()
	var enemy_attack_range = actor.get_attack_range()

	if distance_from_player <= enemy_attack_range:
		return SUCCESS
	else:
		return FAILURE
```

In this example we have extended the `ConditionLeaf` to create `IsPlayerWithinAttackRange`. This condition could be part of a behavior tree used by an enemy, which in this case would be the `Node` referenced by the `actor` parameter. Our enemy node provides us access to a `get_distance_from_player` and a `get_attack_range` function which are used to determine if the player is within attack range. If `distance_from_player` is less than or equal to `enemy_attack_range` then we would return `SUCCESS` and the behavior tree would continue execution of an attack sequence. If `distance_from_player` is greater than `enemy_attack_range` then we would return `FAILURE` and we would not execute the attack sequence.