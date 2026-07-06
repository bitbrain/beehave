![logo](docs/assets/logo.svg)

[![beehave-ci](https://github.com/bitbrain/beehave/actions/workflows/beehave-ci.yml/badge.svg)](https://github.com/bitbrain/beehave/actions/workflows/beehave-ci.yml) [![](https://img.shields.io/discord/785246324793540608.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.com/invite/CKBuE5djXe) [![](https://img.shields.io/badge/%20%F0%9F%90%9D%20swag!%20-shop.bitbra.in-blueviolet)](https://shop.bitbra.in)

---

**[Beehave](https://bitbra.in/beehave) is a powerful addon for Godot Engine that enables you to create robust AI systems using behavior trees.** With Beehave, you can easily design complex NPC behaviors, build challenging boss battles, and create other advanced setups with ease.

Using behavior trees, Beehave makes it simple to create highly adaptive AI that responds to changes in the game world and overcomes unexpected obstacles. Whether you are a beginner or an experienced developer, Beehave is the perfect tool to take your game AI to the next level.

# 🐝 Features

### 🤖 Node based - build behavior trees within your scene tree

Compose behavior trees in your scene and attach them to any node of your choice.

<img src="docs/assets/beehave-demo-tree.png" width="450px"/>

### 🐛 Debug view - a dedicated debug view to analyze your behavior at runtime

A dedicated debug view inside the Godot editor allows you to better understand what the behavior is doing under the hood.

<img src="docs/assets/debug-tree.gif" width="450px"/>

### 🚗 Performance - built-in monitors to track performance of your behavior trees

Maintaining high framerate is important in games. Investigate performance issues by using the custom monitor available inside the Godot editor.

<img src="docs/assets/performance-monitor.gif" width="450px"/>

### 🧪 Tested - any functionality of this addon is covered by test automation

In order to avoid bugs creeping into the codebase, every feature is covered by unit tests.

<img src="docs/assets/gdunit-testrun.gif" width="450px"/>

# 📊 Benchmarks

Beehave ships with a [benchmark suite](benchmark/README.md) that measures the addon as a black box through its public API. The headline metric: a full 13-node patrol/chase/attack behavior tree per agent, all agents ticked every frame.

![agent-scaling](benchmark/results/macro_agents.svg)

![per-node-cost](benchmark/results/micro_nodes.svg)

Measured on `2026-07-06` | Beehave `2.9.3-dev` | Godot `4.7-stable` (editor build) | Linux | AMD Ryzen 7 9800X3D. Full tables including p95/p99 percentiles are in [benchmark/results/results.md](benchmark/results/results.md) and the methodology is documented in [benchmark/README.md](benchmark/README.md). Regenerate locally with:

```bash
godot --headless --path . res://benchmark/benchmark.tscn
```

# 📦 Installation

1. [Download Latest Release](https://github.com/bitbrain/beehave/releases/latest)
   - (optional) access latest build for [Godot 3.x](https://github.com/bitbrain/beehave/archive/refs/heads/godot-3.x.zip), [Godot 4.x](https://github.com/bitbrain/beehave/archive/refs/heads/godot-4.x.zip)
2. Unpack the `addons/beehave` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`
4. Move `script_templates` into your project folder.

To better understand what branch to choose from for which Godot version, please refer to this table:
|Godot Version|Beehave Branch|Beehave Version|
|---|---|--|
|`3.x`|`3.x`|`1.x`|
|`4.x`|`4.x`|`2.x`|
|`4.5+`|`4.x`|`2.10+`|
|`4.1.x`|`4.x`|`2.9.x`|
|`4.0.x`|`4.x`|`2.7.x`|

Refer to [this guide](https://bitbra.in/blog/godot-addon-compatibility/) for more details behind this structure.

# 📚 Getting started

Behavior trees are a modular way to build AI logic for your game. For simple AI, behavior trees are definitely overkill, however, for more complex AI interactions, behavior trees can help you to better manage changes and re-use logic across all NPCs.

![example](docs/assets/example.png)

[Learn how to beehave on the official wiki!](https://bitbra.in/beehave/#/manual/)

## Media

### Beehave Overview (Gamefromscratch)
[![tutorial-thumbnail](https://img.youtube.com/vi/egutKInUfko/0.jpg)](https://www.youtube.com/watch?v=egutKInUfko)

### Godot 4.x Tutorial
[![tutorial-thumbnail](https://img.youtube.com/vi/aru_FojSqDo/0.jpg)](https://www.youtube.com/watch?v=aru_FojSqDo)

### Godot 3.5 Tutorial
[bitbrain](https://youtube.com/@bitbraindev) recorded this tutorial to show in more depth how to use this addon:

[![tutorial-thumbnail](https://img.youtube.com/vi/n0gVEA1dyPQ/0.jpg)](https://www.youtube.com/watch?v=n0gVEA1dyPQ)


### Getting Started with Beehave (Liam Flannery)
[Liam Flannery](https://twitter.com/liamflannery56) wrote up a getting started [tutorial](https://medium.com/@liam.flannery56/easily-creating-behaviour-trees-in-godot-4-2-beehave-tutorial-ff8a911d43a0) that's up to date with Godot 4.2

# 🥰 Credits

- logo designs by [@NathanHoad](https://twitter.com/nathanhoad) & [@StuartDeVille](https://twitter.com/StuartDeVille)
- original addon by [@viniciusgerevini](https://github.com/viniciusgerevini)
- icon design by [@lostptr](https://github.com/lostptr)
