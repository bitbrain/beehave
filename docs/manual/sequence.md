# Sequence Node
The Sequence node is a fundamental building block in Behavior Trees, used to execute a series of child nodes in a specific order. It helps you define the order of actions or tasks that your game characters or objects will follow.

## How does it work?
The Sequence node tries to execute all its children one by one, in the order they are connected. It reports a `SUCCESS` status code if all children report `SUCCESS`. If at least one child reports a `FAILURE` status code, the Sequence node also returns `FAILURE`.

> **Note for beginners:** In game development, a "tick" refers to a single frame or iteration in the game loop. The game loop constantly updates and renders the game world based on the game's logic.

Every tick, the Sequence node processes all its children, even if one of them is currently `RUNNING`.

### Types of Sequence Nodes
There are three variations of Sequence nodes, each with different behaviors based on their child node status:

Type of Node | Child returns `FAILURE` | Child returns `RUNNING`
-------------|------------------------|-------------------------
`SequenceComposite` | Restart | Tick again
`SequenceReactiveComposite` | Restart | Restart
`SequenceStarComposite` | Tick again | Tick again

## Sequence Random
The Sequence Random node behaves similarly to the Sequence Star node, but instead of executing its children in the given order, it executes them in a random order.

## Example Scenarios
Here are some example scenarios to help you understand the Sequence node better:

### Example 1: Basic Patrol
Imagine you want a guard character to follow a patrol route. You can use a Sequence node with the following child nodes:

1. Move to point A
2. Wait for 2 seconds
3. Move to point B
4. Wait for 2 seconds

The guard will follow this sequence, and if all actions are successful, the Sequence node will return `SUCCESS`.

### Example 2: NPC Conversation
An NPC in your game should have a conversation with the player when they approach. You can use a Sequence node with the following child nodes:

1. Check if the player is in range
2. Display a conversation UI
3. Wait for the player's input
4. Respond based on the player's choice

If any of these tasks fail (e.g., the player moves out of range), the Sequence node will return `FAILURE`.

Remember to experiment with different Sequence node types and combine them with other Behavior Tree nodes to create more complex behaviors for your game characters.
