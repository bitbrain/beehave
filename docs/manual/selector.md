# Selector Node
The Selector node is another fundamental building block in Behavior Trees, used to manage decision-making among multiple child nodes. It helps you define different behaviors for your game characters or objects based on varying conditions.

## How does it work?
The Selector node tries to execute each of its children one by one, in the order they are connected. It reports a `SUCCESS` status code if any child reports a `SUCCESS`. If all children report a `FAILURE` status code, the Selector node also returns `FAILURE`.

Every tick, the Selector node processes all its children, even if one of them is currently `RUNNING`.

### Types of Selector Nodes
There are two variations of Selector nodes, each with different behaviors based on their child node status:

Type of Node | Child returns `RUNNING`
-------------|-------------------------
`SelectorComposite` | Tick again
`SelectorReactiveComposite` | Restart

`Tick again` means that it will (for each consecutive tick) skip previous nodes that already ran and tick **only** the current `RUNNING` node again until it is no longer `RUNNING`.

`Restart` means that it will tick all previous nodes that already ran and then tick the current `RUNNING` node again.

### When to Use Restart vs Tick Again

The choice between "restart" and "tick again" behaviors impacts how your selector responds to dynamic game environments:

#### When to Use "Tick Again" Behavior
Choose a selector with "tick again" behavior (`SelectorComposite`) when you need to:

- **Maintain action continuity**: Ensure long-running tasks complete without interruption
- **Preserve computational resources**: Avoid re-checking conditions that are unlikely to change
- **Create stable, predictable behavior**: When commitment to the current action is more important than responsiveness

**Example**: A character performing a special ability that must complete its full animation sequence before considering other options.

```
SelectorComposite
├─ IsSpecialAbilityTriggered (Condition: success)
│  └─ PerformSpecialAbility (Action: running)
├─ IsEnemyNearby (Condition: not evaluated while ability is running)
└─ Patrol (Action: not evaluated while ability is running)
```

#### When to Use "Restart" Behavior
Choose a selector with "restart" behavior (`SelectorReactiveComposite`) when you need to:

- **Prioritize responsiveness**: Immediately react to changing high-priority conditions
- **Implement interrupt-driven behavior**: Allow higher-priority tasks to interrupt lower-priority ones
- **Handle volatile environments**: Re-evaluate all options when the game state changes frequently

**Example**: An AI that should immediately respond to threats regardless of current activities.

```
SelectorReactiveComposite
├─ IsUnderAttack (Condition: initially failure, later success)
│  └─ DefendSelf (Action: will interrupt ongoing tasks when under attack)
├─ IsHungry (Condition: success)
└─ SearchForFood (Action: interrupted when attack detected)
```

The "tick again" approach improves performance and ensures action completion, while "restart" provides greater adaptability to changing conditions at the cost of potentially interrupting ongoing tasks.

## Selector Random
The `SelectorRandomComposite` node behaves similarly to the Selector Star node, but instead of executing its children in the given order, it executes them in a random order.

## Example Scenarios
Here are some example scenarios to help you understand the Selector node better:

### Example 1: Enemy Decision Making
Imagine an enemy character that should decide between different actions based on the player's position. You can use a Selector node with the following child nodes:

1. If the player is far away, patrol the area
2. If the player is in range, attack the player
3. If the player is close and the enemy is low on health, retreat

The enemy will choose the first successful option, and the Selector node will return `SUCCESS`. If none of the conditions are met, the Selector node will return `FAILURE`.

<ul style="list-style: none;">
	<li>
		<img src="assets/icons/tree.svg" width="18px"/>
		BeehaveTree
	</li>
	<ul style="list-style: none;">
		<li>
			<a href="#/manual/selector?id=selector-node"><img src="assets/icons/selector.svg" width="18px"/></a>
			SelectorComposite
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
							<a href="#/manual/condition_leaf?id=condition-leaf"><img src="assets/icons/condition.svg" width="18px"/></a>
							IsPlayerFarAway
						</li>
						<li>
							<a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
							PatrolTheArea
						</li>
					</ul>
				</li>
			</ul>
		</li>
		<li>
			<ul style="list-style: none;">
				<li>
					<a href="#/manual/sequence?id=sequence-node"><img src="assets/icons/sequence.svg" width="18px"/></a>
					SequenceComposite2
				</li>
				<li>
					<ul style="list-style: none;">
						<li>
							<a href="#/manual/condition_leaf?id=condition-leaf"><img src="assets/icons/condition.svg" width="18px"/></a>
							IsPlayerClose
						</li>
						<li>
							<a href="#/manual/condition_leaf?id=condition-leaf"><img src="assets/icons/condition.svg" width="18px"/></a>
							IsHPLow
						</li>
						<li>
							<a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
							Retreat
						</li>
					</ul>
				</li>
			</ul>
		</li>
		<li>
			<ul style="list-style: none;">
				<li>
					<a href="#/manual/sequence?id=sequence-node"><img src="assets/icons/sequence.svg" width="18px"/></a>
					SequenceComposite3
				</li>
				<li>
					<ul style="list-style: none;">
						<li>
							<a href="#/manual/condition_leaf?id=condition-leaf"><img src="assets/icons/condition.svg" width="18px"/></a>
							IsPlayerClose
						</li>
						<li>
							<a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
							AttackPlayer
						</li>
					</ul>
				</li>
			</ul>
		</li>
	</ul>
</ul>

Note, that the "If the player is close and the enemy is low on health, retreat" sequence goes before "If the player is in range, attack the player". If you put them the other way around, the enemy would always keep attacking the player as SelectorSequence will always run the first sequence that doesn't return `FAILURE`.

### Example 2: NPC Reactions
An NPC in your game should react differently based on the player's reputation. You can use a Selector node with the following child nodes:

1. If the player has a high reputation, greet the player warmly
2. If the player has a neutral reputation, greet the player indifferently
3. If the player has a low reputation, act hostile towards the player

The NPC will choose the first successful option, and the Selector node will return `SUCCESS`. If none of the conditions are met, the Selector node will return `FAILURE`.

Experiment with different Selector node types and combine them with other Behavior Tree nodes to create more complex decision-making for your game characters.
