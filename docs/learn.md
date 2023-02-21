# Learn how Beehave works

Behavior trees are a modular way to build AI logic for your game. For simple AI, behavior trees are definitely overkill, however, for more complex AI interactions, behavior trees can help you to better manage changes and re-use logic across all NPCs.

## What is a behavior tree?

In a nutshell, a behavior tree is a Godot Node that can be added as a child to other Godot nodes within the scene tree. It will run its logic every frame tick and modify the parent node accordingly.

In more theoretical terms, a behavior tree consists of so called **nodes** - each node can be of a different type with different purposes. Those are described further down below in more detail. Every node has a `tick(actor, blackboard)` method that can be used to execute custom logic. When the `tick` function is called, beehave expects a return status of either `SUCCESS`, `RUNNING` or `FAILURE`.

In **Beehave**, every behavior tree is of type `BeehaveTree`. Attach that node to any node to any other node you want to apply the behavior tree to.

## Tutorial (Godot 3.5+)

I have recorded this tutorial to show in more depth how to use this addon:

[![tutorial-thumbnail](https://img.youtube.com/vi/n0gVEA1dyPQ/0.jpg)](https://www.youtube.com/watch?v=n0gVEA1dyPQ)

## Actions and Conditions

Conditions are **leaf nodes** of type `ConditionLeaf`. They should be kept simple and either return `SUCCESS` or `FAILURE` depending on a single condition. Avoid creating conditions that check multiple things as it will become more difficult to reuse these nodes.

**1. Example Condition code: IsVisibleCondition.gd**

```gdscript
class_name IsVisibleCondition extends ConditionLeaf

func tick(actor:Node, blackboard:Blackboard) -> int:
    if actor.visible:
        return SUCCESS
    return FAILURE
```

Actions are **leaf nodes** of type `ActionLeaf`. They can be long running potentially being called across multiple frame executions. In this case return the code `RUNNING` .

**2. Example Action code: MakeVisibleAction.gd**

```gdscript
class_name MakeVisibleAction extends ActionLeaf

func tick(actor:Node, blackboard:Blackboard) -> int:
    if actor.visible:
        return FAILURE
    actor.visible = true
    return SUCCESS
```

