# Decorators
Decorators are versatile nodes that can be combined with any other nodes described in this guide. They can modify or alter the behavior of their child node(s), providing additional flexibility and control in the behavior tree.

## Failer
A `Failer` node will always return a `FAILURE` status code, regardless of the result of its child node. This can be useful in cases where you want to force a branch to fail, such as when an optional action is not critical for the overall success of the behavior tree.

**Example:** An NPC trying to pick up an item, even if the action fails, the NPC can continue with other tasks.

## Succeeder
A `Succeeder` node will always return a `SUCCESS` status code, no matter the outcome of its child node. This can be helpful when you want to ensure that a branch is considered successful, even if the actual action or condition fails.

**Example:** An NPC attempts to open a door, but even if the door is locked, the NPC continues with its routine as if the door was opened.

## Inverter
An `Inverter` node reverses the outcome of its child node. It returns `FAILURE` if its child returns a `SUCCESS` status code, and `SUCCESS` if its child returns a `FAILURE` status code. This is useful when you want to negate a condition or invert the result of an action.

**Example:** An NPC is patrolling an area and should change its path if it *doesn't* detect an enemy.

## Limiter
The `Limiter` node executes its child a specified number of times (x). When the maximum number of ticks is reached, it returns a `FAILURE` status code. This can be beneficial when you want to limit the number of times an action or condition is executed, such as limiting the number of attempts an NPC makes to perform a task. Once a limiter reaches its maximum number of ticks, it will start interrupting its child on every tick.

**Example:** An NPC tries to unlock a door with lockpicks but will give up after three attempts if unsuccessful.

## TimeLimiter
The `TimeLimiter` node only gives its child a set amount of time to finish. When the time is up, it interrupts its child and returns a `FAILURE` status code. This is useful when you want to limit the execution time of a long running action. Once a time limiter reaches its time limit, it will start interrupting its child on every tick.

**Example:** A mob aggros and tries to chase you, the chase action will last a maximum of 10 seconds before being aborted if not complete.
