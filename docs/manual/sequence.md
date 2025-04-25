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

`Restart` means that it will tick all previous nodes that already ran and then tick the current `RUNNING` node again.

`Tick again` means that it will (for each consecutive tick) skip previous nodes that already ran and tick **only** the current `RUNNING` node again until it is no longer `RUNNING`.

### When to Use Restart vs Tick Again

The choice between "restart" and "tick again" behaviors has significant impacts on your sequence's effectiveness in different scenarios:

#### When to Use "Restart" Behavior
Choose a sequence with "restart" behavior when you need to:

- **Validate preconditions continuously**: Ensure all previous steps still hold true while executing a sequence
- **Handle dynamic environments**: Re-check environmental conditions that might change during execution
- **Maintain safety checks**: For critical operations where all conditions must remain valid throughout

**Example**: A character needs to pick up and use an item that might be taken by another character. Using `SequenceReactiveComposite` would re-check if the item is still available before attempting to use it.

```
SequenceReactiveComposite
├─ IsItemAvailable (Condition)
├─ MoveToItem (Action: running)
└─ UseItem (Action)
```

#### When to Use "Tick Again" Behavior
Choose a sequence with "tick again" behavior when you need to:

- **Optimize performance**: Avoid redundant checks of conditions that won't change
- **Complete multi-step procedures**: Ensure a procedure completes without unnecessary rechecking
- **Create predictable, deterministic behavior**: When you want guaranteed completion of a series of steps

**Example**: A character performing a complex animation sequence that should complete regardless of minor environmental changes would benefit from `SequenceStarComposite`.

```
SequenceStarComposite
├─ StartAnimation (Action: success)
├─ PlayMainAnimation (Action: running)
└─ EndAnimation (Action)
```

The performance benefits of "tick again" come at the cost of responsiveness to changing conditions, while "restart" provides better adaptability but with higher computational overhead.

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

<ul style="list-style: none;">
    <li>
        <img src="assets/icons/tree.svg" width="18px"/>
        BeehaveTree
    </li>
    <li>
        <ul style="list-style: none;">
            <li>
                <a href="#/manual/sequence?id=sequence-node"><img src="assets/icons/sequence.svg" width="18px"/></a>
                SequenceComposite
            </li>
            <li>
                <ul style="list-style: none;">
                    <li>
                        <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                        MoveToPointA
                    </li>
                    <li>
                        <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                        WaitFor2Seconds
                    </li>
                    <li>
                        <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                        MoveToPointB
                    </li>
                    <li>
                        <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                        WaitFor2Seconds2
                    </li>
                </ul>
            </li>
        </ul>
    </li>
</ul>

Instead of creating a custom action for waiting, you could use the <a href="#/manual/decorators?id=delayer">Delayer</a> decorator.


### Example 2: NPC Conversation
An NPC in your game should have a conversation with the player when they approach. You can use a Sequence node with the following child nodes:

1. Check if the player is in range
2. Display a conversation UI
3. Wait for the player's input
4. Respond based on the player's choice

If any of these tasks fail (e.g., the player moves out of range), the Sequence node will return `FAILURE`.

Remember to experiment with different Sequence node types and combine them with other Behavior Tree nodes to create more complex behaviors for your game characters.
