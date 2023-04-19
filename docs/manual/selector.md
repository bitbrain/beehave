# Selector Node
The Selector node is another fundamental building block in Behavior Trees, used to manage decision-making among multiple child nodes. It helps you define different behaviors for your game characters or objects based on varying conditions.

## How does it work?
The Selector node tries to execute each of its children one by one, in the order they are connected. It reports a `SUCCESS` status code if any child reports a `SUCCESS`. If all children report a `FAILURE` status code, the Selector node also returns `FAILURE`.

Every tick, the Selector node processes all its children, even if one of them is currently `RUNNING`.

### Types of Selector Nodes
There are two variations of Selector nodes, each with different behaviors based on their child node status:

Type of Node | Child returns `RUNNING`
-------------|-------------------------
`SelectorComposite` | Tick again
`SelectorReactiveComposite` | Restart

## Selector Random
The `SelectorRandomComposite` node behaves similarly to the Selector Star node, but instead of executing its children in the given order, it executes them in a random order.

## Example Scenarios
Here are some example scenarios to help you understand the Selector node better:

### Example 1: Enemy Decision Making
Imagine an enemy character that should decide between different actions based on the player's position. You can use a Selector node with the following child nodes:

1. If the player is far away, patrol the area
2. If the player is in range, attack the player
3. If the player is close and the enemy is low on health, retreat

The enemy will choose the first successful option, and the Selector node will return `SUCCESS`. If none of the conditions are met, the Selector node will return `FAILURE`.

### Example 2: NPC Reactions
An NPC in your game should react differently based on the player's reputation. You can use a Selector node with the following child nodes:

1. If the player has a high reputation, greet the player warmly
2. If the player has a neutral reputation, greet the player indifferently
3. If the player has a low reputation, act hostile towards the player

The NPC will choose the first successful option, and the Selector node will return `SUCCESS`. If none of the conditions are met, the Selector node will return `FAILURE`.

Experiment with different Selector node types and combine them with other Behavior Tree nodes to create more complex decision-making for your game characters.
