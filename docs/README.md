# Behavior tree AI for Godot Engine!

![](https://img.shields.io/badge/Godot%20Compatible-4.0%2B-%234385B5) ![](https://img.shields.io/badge/Godot%20Compatible-3.0%2B-%234385B5) [![](https://img.shields.io/discord/785246324793540608.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.com/invite/CKBuE5djXe) [![](https://img.shields.io/badge/%20%F0%9F%90%9D%20swag!%20-shop.bitbra.in-blueviolet)](https://shop.bitbra.in)

> ⚠ **Disclaimer: Godot 4 is not released yet. As a result, the version for Godot 4 may be unstable to use and the API may change. Please keep using [the stable 3.x branch](https://github.com/bitbrain/beehave/tree/godot-3.x) if you do not want to have breaking changes in your game.**

Behaviour trees are a modular way to build AI logic for your game. For simple AI, behaviour trees are definitely overkill, however, for more complex AI interactions, behaviour trees can help you to better manage changes and re-use logic across all NPCs.

## What is a behavior tree?

In a nutshell, a behaviour tree is a Godot Node that can be added as a child to other Godot nodes within the scene tree. It will run its logic every frame tick and modify the parent node accordingly.

In more theoretical terms, a behaviour tree consists of so called **nodes** - each node can be of a different type with different purposes. Those are described further down below in more detail. Every node has a `tick(actor, blackboard)` method that can be used to execute custom logic. When the `tick` function is called, beehave expects a return status of either `SUCCESS`, `RUNNING` or `FAILURE`.

In **Beehave**, every behaviour tree is of type ![icon](addons/beehave/icons/tree.svg) `BeehaveTree`. Attach that node to any node to any other node you want to apply the behaviour tree to.

## Tutorial (Godot 3.5+)

I have recorded this tutorial to show in more depth how to use this addon:

[![tutorial-thumbnail](https://img.youtube.com/vi/n0gVEA1dyPQ/0.jpg)](https://www.youtube.com/watch?v=n0gVEA1dyPQ)

