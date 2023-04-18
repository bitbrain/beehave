# Getting Started with Beehave

Beehave is an addon for the Godot Engine, designed to help you build Artificial Intelligence (AI) logic for your game using Behavior Trees. For simple AI, Behavior Trees might be more complex than needed. However, when dealing with more intricate AI interactions, Behavior Trees can help you better manage changes and reuse logic across all Non-Player Characters (NPCs).

## What is a Behavior Tree?

At a high level, a Behavior Tree is a Godot Node that can be added as a child to other Godot nodes within the scene tree. It runs its logic every frame tick and modifies the parent node accordingly.

More specifically, a Behavior Tree is composed of **nodes** that can have various types and purposes, each with its own custom logic. Every node has a `tick(actor, blackboard)` method. When the `tick` function is called, Beehave expects a return status of either `SUCCESS`, `RUNNING`, or `FAILURE`.

In Beehave, every Behavior Tree is of type `BeehaveTree`. Attach this node to any other node you want to apply the Behavior Tree to.

## Tutorial (Godot 3.5+)

For an in-depth tutorial on how to use the Beehave addon, watch the video below:

[![tutorial-thumbnail](https://img.youtube.com/vi/n0gVEA1dyPQ/0.jpg)](https://www.youtube.com/watch?v=n0gVEA1dyPQ)

## Actions and Conditions

In Beehave, **Conditions** are leaf nodes of type `ConditionLeaf`. They are simple nodes that return either `SUCCESS` or `FAILURE`, based on a single condition. To maximize reusability, avoid creating conditions that check multiple factors.

**1. Example Condition Code: IsVisibleCondition.gd**

```gdscript
class_name IsVisibleCondition extends ConditionLeaf

func tick(actor:Node, blackboard:Blackboard) -> int:
    if actor.visible:
        return SUCCESS
    return FAILURE
```

**2. Example Action Code: MakeVisibleAction.gd**

```gdscript
class_name MakeVisibleAction extends ActionLeaf

func tick(actor:Node, blackboard:Blackboard) -> int:
    if actor.visible:
        return FAILURE
    actor.visible = true
    return SUCCESS
```
With these basic concepts in mind, you're ready to start building your game's AI logic using Beehave and Behavior Trees. Experiment with different node types and combinations to create complex behaviors for your game characters.