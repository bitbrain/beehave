# Leaf Nodes

Leaf nodes are the fundamental building blocks of behavior trees that perform the actual work. Unlike composite nodes and decorators which control flow, leaf nodes are where the behavior tree interacts with the game world.

## What are Leaf Nodes?

Leaf nodes are the terminal nodes in a behavior tree - they have no children and represent concrete actions or conditions that can be executed. They are called "leaf" nodes because they sit at the ends of branches in the tree structure.

In Beehave, there are two primary types of leaf nodes:

- **Action Nodes**: Perform actions that change the game state
- **Condition Nodes**: Check conditions in the game state

## Key Characteristics

- Leaf nodes always return a status: `SUCCESS`, `FAILURE`, or `RUNNING`
- They interact directly with the game world or check game state
- They have no child nodes
- They are where the "real work" happens in your behavior tree

## When to Use Leaf Nodes

You'll create leaf nodes whenever you need your AI to:

- Perform a specific action (move to a location, play an animation, attack)
- Check a specific condition (is health low, is enemy visible, is item available)

## Creating Custom Leaf Nodes

While Beehave provides basic Action and Condition leaf nodes, you'll typically create your own custom leaf nodes for your specific game mechanics. This allows you to encapsulate game-specific logic within reusable components.

For detailed information on the specific leaf node types, see:
- [Action Leaf](manual/action_leaf.md)
- [Condition Leaf](manual/condition_leaf.md)

## Example

Here's a simplified example of how leaf nodes fit into a behavior tree:

```
Selector
├── Sequence
│   ├── IsEnemyVisible (Condition Leaf)
│   └── AttackEnemy (Action Leaf)
└── Sequence
    ├── IsWanderPointAvailable (Condition Leaf)
    └── WanderToPoint (Action Leaf)
```

In this example, the leaf nodes (`IsEnemyVisible`, `AttackEnemy`, `IsWanderPointAvailable`, and `WanderToPoint`) are where the actual game logic happens.

## Next Steps

To learn more about specific leaf node types, continue to:
- [Action Leaf](manual/action_leaf.md)
- [Condition Leaf](manual/condition_leaf.md)
