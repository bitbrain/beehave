# Action Leaf Node

The `ActionLeaf` node is a key element in Behavior Trees, designed to represent *ACTIONS* that game characters or objects perform, such as _gathering wood_ or _fishing_. As leaf nodes, they don't have any children and are responsible for executing the specific task in the game.

## How does it work?
`ActionLeaf` nodes should return a custom user value depending on the result of the action. Since actions can potentially span across multiple frames, they should return `RUNNING` when the action is still being executed.

When the action is completed successfully, the `ActionLeaf` node should return `SUCCESS`. If the action fails or is interrupted, it should return `FAILURE`.

## Example Scenarios
Here are some example scenarios to help you understand the `ActionLeaf` node better:

### Example 1: Gathering Wood
Imagine you have a character that can gather wood in your game. You can use an `ActionLeaf` node to represent this action:

1. If the character is close to a tree, start gathering wood
2. If the character gathers the required amount of wood, return `SUCCESS`
3. If the character is interrupted or cannot gather wood, return `FAILURE`

### Example 2: Fishing
In another example, you have a character that can fish. You can use an `ActionLeaf` node to represent this action:

1. If the character is near a body of water, start fishing
2. If the character catches a fish, return `SUCCESS`
3. If the character is interrupted or fails to catch a fish, return `FAILURE`

Combine `ActionLeaf` nodes with other Behavior Tree nodes to create complex actions and behaviors for your game characters.
