# Core Concepts in Beehave

Before diving into creating behavior trees, let's understand the fundamental concepts that make up the Beehave system.

## The Three Status Codes

Every node in a behavior tree returns one of three status codes:

- **SUCCESS**: The node has completed its task successfully and achieved its goal
- **FAILURE**: The node has failed to complete its task or its conditions weren't met
- **RUNNING**: The node is still working on its task and needs more time to complete

These status codes propagate up the tree and determine how parent nodes behave. When a node returns RUNNING, it will be revisited on the next tick until it returns SUCCESS or FAILURE.

## Node Types

Beehave provides several types of nodes that serve different purposes:

### Leaf Nodes

Leaf nodes are at the ends of branches and perform actual actions or check conditions:

- **Action Nodes**: Perform actions like "Move to position", "Attack enemy", or "Play animation". These nodes do the actual work and can return any of the three status codes.
- **Condition Nodes**: Check conditions like "Is enemy visible?", "Is health low?", or "Is item available?". These nodes typically return SUCCESS if the condition is true and FAILURE if it's false.

### Composite Nodes

Composite nodes control the flow by managing multiple child nodes:

- **Sequence**: Executes children in order until one fails (AND logic). Returns SUCCESS only if all children succeed. If any child fails, the sequence stops and returns FAILURE.
- **Selector**: Executes children in order until one succeeds (OR logic). Returns SUCCESS if any child succeeds. If all children fail, the selector returns FAILURE.
- **Simple Parallel**: Executes two children simultaneously - typically a main task and a background task. The node can be configured to succeed when the main task succeeds or when both tasks succeed. See [Simple Parallel](./composites/simple_parallel.md) for more details.

### Decorator Nodes

Decorator nodes modify the behavior of their single child node:

- **Inverter**: Reverses the result (SUCCESS becomes FAILURE and vice versa)
- **Succeeder**: Always returns SUCCESS regardless of the child's result
- **Failer**: Always returns FAILURE regardless of the child's result
- **Limiter**: Limits how many times a node can be executed
- **Repeater**: Repeats a node multiple times
- **UntilFail**: Continues executing its child until the child returns FAILURE

Decorators are perfect for modifying behavior without changing the underlying nodes. For example, an Inverter turns "Is Enemy Visible" into "Is Enemy Not Visible" without creating a new condition.

## The Blackboard

The Blackboard is a shared memory space that nodes can use to store and retrieve information. Think of it as a central database where your AI behaviors can communicate with each other.

### Key Blackboard Concepts

- **Data Sharing**: The blackboard allows different parts of the behavior tree to exchange information
- **Persistence**: Data remains on the blackboard between ticks, serving as the AI's memory
- **Scoping**: Blackboard data can be scoped to specific trees or branches (see [Blackboard](blackboard.md))

### Blackboard Example

A behavior tree for an enemy character might use the blackboard like this:

1. A perception node finds the player and writes:
   ```gdscript
   blackboard.set_value("player_position", player.global_position)
   blackboard.set_value("player_detected", true)
   ```

2. Later, a movement node reads this data:
   ```gdscript
   var target = blackboard.get_value("player_position")
   # Move toward target...
   ```

3. And a combat node might check:
   ```gdscript
   if blackboard.get_value("player_detected", false):
       # Attack player...
   ```

Using the blackboard this way keeps your nodes decoupled and reusable.

## How Execution Works

Understanding how behavior trees execute is crucial:

1. Every tick (usually every frame), the tree starts execution from the root node
2. The root node ticks its children according to its type (Sequence, Selector, etc.)
3. Execution continues down the tree until leaf nodes are reached
4. Leaf nodes perform actions or check conditions and return a status
5. The status propagates back up the tree, determining which nodes execute next

This continual reevaluation allows the AI to respond to changing conditions in the game world.

### Execution Example

Consider this sequence: "Check if enemy is visible" → "Move to enemy" → "Attack enemy"

- On the first tick, if "Check if enemy is visible" returns FAILURE, the entire sequence fails
- If it returns SUCCESS, "Move to enemy" executes and might return RUNNING
- On subsequent ticks, the sequence resumes at "Move to enemy" until it succeeds
- Only then does "Attack enemy" execute

## Visual Example

Here's a visualization of how a simple behavior tree executes:

![Behavior Tree Execution](../assets/bt_execution_flow.png)

In this example:
1. The Selector node checks its first child (Sequence)
2. The Sequence node checks if the enemy is visible
3. If yes, it moves to the enemy and attacks
4. If the enemy isn't visible or any part of the sequence fails, the Selector moves to its second child
5. The second sequence makes the AI patrol the area

## Common Patterns

Some useful behavior tree patterns include:

- **Guard Pattern**: A condition followed by an action in a sequence, ensuring the action only runs when the condition is met
- **Priority Selector**: Arranging options in order of preference using a selector
- **State Machine**: Using selectors and sequences to model different states and transitions

## Performance Tips

- Avoid expensive operations in frequently-executed conditions
- Use the Limiter decorator for operations that don't need to run every tick
- Keep your trees organized and not too deep for better debugging

Now that you understand the core concepts, let's move on to [creating your first behavior tree](first_behavior_tree.md) or learn more about [blackboards](blackboard.md). 