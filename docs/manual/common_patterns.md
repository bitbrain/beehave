

# Common Patterns & Examples

This page describes advanced behavior tree patterns and provides practical examples. These patterns build on the core concepts covered in previous sections.

## Guard Pattern

A guard pattern uses a condition to protect the execution of a subtree, ensuring it only runs when appropriate. 

````
Sequence
├── Condition (Guard)
└── Action or Subtree (Protected behavior)
````

**Why it's useful:** Imagine your boss monster trying to execute its devastating area attack when no players are nearby. Without a guard pattern, it would waste the cooldown and animation playing to an empty room! The guard pattern ensures behaviors only trigger when they make sense.

### Example: Guarded Attack

````
Sequence
├── IsEnemyInRange
└── AttackEnemy
````

In a dungeon crawler, your skeleton archer will only draw its bow when enemies are actually in range, saving processing power and preventing the "shooting at walls" syndrome that plagues so many game AIs.

## Memory Pattern

The memory pattern uses the blackboard to remember information between ticks, allowing nodes to make decisions based on past events.

````
Sequence
├── Condition (Stores result in blackboard)
└── Action (Uses stored result)
````

**Why it's useful:** Without memory, your AI would be like Dory from Finding Nemo - seeing the player, then immediately forgetting where they went the moment they step behind a wall. Memory patterns create more believable "object permanence" in your AI.

### Example: Remember Last Seen Position

````gdscript
// SpotAndRememberPlayer.gd
class_name SpotAndRememberPlayer extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
    var player = get_tree().get_first_node_in_group("player")
    if player and actor.can_see(player):
        // Remember where we saw the player
        blackboard.set_value("last_seen_position", player.global_position)
        blackboard.set_value("last_seen_time", Time.get_ticks_msec())
        return SUCCESS
    return FAILURE
````

In a stealth game, guards will investigate the last place they saw you rather than instantly forgetting your existence the moment you duck behind cover. This creates those tense moments where you're hiding in a locker while the guard searches exactly where they last spotted you.

## Cooldown Pattern

This pattern implements a cooldown on actions using the Cooldown decorator.

````
Cooldown (seconds)
└── Action (Action with cooldown)
````

**Why it's useful:** Without cooldowns, your mage enemy might cast Fireball 60 times per second, turning your carefully balanced boss fight into a CPU-melting inferno of particle effects. Cooldowns create rhythm in combat and prevent ability spam.

### Example: Special Attack with Cooldown

````
Cooldown (5.0)
└── SpecialAttack
````

In an action RPG, the troll boss will only attempt its ground-pound attack every 5 seconds, giving players a window to attack safely after dodging it, rather than being subjected to an endless earthquake.

## Parallel Activity Pattern

This pattern uses SimpleParallel to perform a background activity while working on a main task.

````
SimpleParallel
├── MainTask (Primary)
└── BackgroundActivity (Secondary)
````

**Why it's useful:** Without parallel activities, your NPCs would look robotic - stopping completely to look around before continuing to walk. Humans naturally multitask, and this pattern helps your AI do the same.

### Example: Look While Moving

````
SimpleParallel
├── MoveToPosition
└── ScanForThreats
````

In a survival horror game, your companion AI can walk toward the exit while simultaneously keeping an eye out for monsters, creating more natural movement instead of the awkward stop-scan-move pattern that makes AI companions feel mechanical.

## Random Selection Pattern

This uses SelectorRandomComposite to choose between equally valid options randomly.

````
SelectorRandom
├── Option1
├── Option2
└── Option3
````

**Why it's useful:** Predictable AI quickly becomes boring. Without randomness, your town NPCs would perform the exact same actions in the exact same order every day, making your game world feel mechanical and scripted.

### Example: Random Idle Animation

````
SelectorRandom
├── PlayIdleAnimation ("idle1")
├── PlayIdleAnimation ("idle2")
└── PlayIdleAnimation ("idle3")
````

In an RPG, villagers will randomly choose between different idle animations - checking their watch, wiping their brow, or adjusting their clothing - making them feel more alive and less like animatronic displays when the player observes them.

## Limited Retry Pattern

This pattern uses a Limiter to restrict how many times an operation is attempted.

````
Limiter (max_attempts)
└── OperationToLimit
````

**Why it's useful:** Without limits, your AI might get stuck in an infinite loop trying the same failing action forever. This pattern prevents AI characters from looking obsessive or glitched when something isn't working.

### Example: Limited Door Unlocking Attempts

````
Limiter (3)
└── Sequence
    ├── ApproachDoor
    └── AttemptToUnlock
````

In a heist game, your AI accomplice will try to pick a lock up to three times before giving up and suggesting an alternative route, rather than standing at the door forever in a futile attempt to open it.

## Time-Limited Action Pattern

Uses TimeLimiter to give a behavior limited time to complete.

````
TimeLimiter (seconds)
└── TimedAction
````

**Why it's useful:** Some actions should have a sense of urgency. Without time limits, your AI might chase the player forever, even across the entire game world, creating frustrating gameplay.

### Example: Time-Limited Chase

````
TimeLimiter (10.0)
└── ChasePlayer
````

In a horror game, the monster will only chase the player for 10 seconds before giving up if it can't catch them, creating tense escape sequences with a chance of relief rather than endless pursuits that force players to restart.

## State Machine Pattern with Blackboard

This pattern implements a state machine using a Selector with Sequence branches and a blackboard to track the current state.

````
Selector
├── Sequence (State 1)
│   ├── IsInState1
│   └── State1Behavior
├── Sequence (State 2)
│   ├── IsInState2
│   └── State2Behavior
└── Sequence (State 3)
    ├── IsInState3
    └── State3Behavior
````

**Why it's useful:** Complex AI needs distinct behavioral modes. Without clear states, your enemy AI might try to both flee and attack simultaneously, resulting in confused, erratic behavior that breaks immersion.

### Example: Enemy AI States

````
// Enemy State Machine Structure
Selector
├── Sequence (Flee State)
│   ├── IsInState ("flee")
│   └── FleeFromPlayer
├── Sequence (Attack State)
│   ├── IsInState ("attack")
│   └── AttackPlayer
└── Sequence (Patrol State)
    ├── IsInState ("patrol")
    └── PatrolArea
````

In an open-world game, bandits have distinct behavioral states - patrolling their camp when unaware of threats, attacking when they spot the player, and fleeing when severely wounded. This creates a dynamic encounter that evolves naturally rather than enemies that mindlessly attack until death.

## UntilFail Loop Pattern

This uses UntilFail to repeat a behavior until it fails.

````
UntilFail
└── BehaviorToRepeat
````

**Why it's useful:** Some behaviors should continue until they can't anymore. Without this pattern, you'd need complex logic to handle repetitive tasks that should only stop under specific conditions.

### Example: Resource Gathering

````
UntilFail
└── Sequence
    ├── FindResource
    ├── MoveToResource
    └── GatherResource
````

In a strategy game, worker units will continue gathering resources until there are none left to find, efficiently automating a repetitive task without needing player micromanagement for each individual resource.

## Advanced Example: Stealth Enemy AI

This example combines multiple patterns to create a complex stealth enemy AI:

````
Selector
├── Sequence (Alert Response)
│   ├── IsAlertTriggered
│   └── Sequence
│       ├── MoveToLastKnownPlayerPosition
│       ├── SimpleParallel
│       │   ├── SearchArea
│       │   └── ScanForPlayer
│       └── Cooldown (5.0)
│           └── CallForReinforcements
├── Sequence (Suspicious Investigation)
│   ├── HeardNoise
│   └── Sequence
│       ├── StopMovement
│       ├── LookAtNoiseSource
│       ├── Delayer (2.0)
│       │   └── WaitAndListen
│       └── MoveToNoiseSource
└── Sequence (Normal Patrol)
    ├── UntilFail
    │   └── Sequence
    │       ├── MoveToNextPatrolPoint
    │       └── Delayer (3.0)
    │           └── LookAround
    └── Inverter
        └── IsPatrolComplete
````

**Why it's useful:** Stealth games require nuanced AI that responds to different levels of awareness. This complex tree creates guards that feel intelligent - investigating noises, calling for help when they spot you, and conducting thorough searches of your last known position.

In a game like "Thief" or "Metal Gear Solid," this behavior tree creates those classic stealth moments where you throw a bottle to distract a guard, who then suspiciously investigates the noise while you slip past. If they spot you, they'll call for backup and thoroughly search your last known location, creating escalating tension rather than immediately returning to patrol as if nothing happened.

## Combining with Blackboards for Team Coordination

This example shows how multiple AI agents can coordinate using a shared blackboard:

````
Selector
├── Sequence (Respond to Team Alert)
│   ├── CheckTeamAlert
│   └── MoveToAlertPosition
├── Sequence (Raise Team Alert)
│   ├── SpotAndRememberPlayer
│   └── RaiseTeamAlert
└── PatrolArea (Normal Behavior)
````

**Why it's useful:** Without team coordination, your enemy squads would act like strangers rather than a cohesive unit. This pattern creates emergent cooperative behavior without having to script specific formations or commands.

In a tactical shooter, when one enemy spots you, they'll shout to alert their teammates (raising a team alert on the blackboard), causing all nearby enemies to converge on your position. This creates realistic squad tactics where enemies work together rather than acting as isolated individuals, making combat more challenging and immersive.

## Delayed Reaction Pattern

This pattern uses the Delayer decorator to create a delayed response to an event.

````
Sequence
├── TriggerEvent
└── Delayer (seconds)
    └── ReactToEvent
````

**Why it's useful:** Not everything should happen instantly. Delayed reactions create anticipation and give players time to react to telegraphed actions.

### Example: Delayed Explosion

````
Sequence
├── PlaceBomb
└── Delayer (3.0)
    └── Explode
````

In an action game, the goblin bomber places a comically large bomb with a visible fuse, then runs away giggling. Three seconds later - BOOM! This creates a fair gameplay mechanic where players have time to escape the blast radius, rather than instant, unavoidable explosions that would feel cheap and frustrating.

## Fallback Chain Pattern

This pattern creates a chain of fallback behaviors, each with its own condition.

````
Selector
├── Sequence (Primary Behavior)
│   ├── CanExecutePrimary
│   └── ExecutePrimary
├── Sequence (Secondary Behavior)
│   ├── CanExecuteSecondary
│   └── ExecuteSecondary
└── FallbackBehavior
````

**Why it's useful:** AI needs graceful degradation of behavior. Without fallbacks, your AI might simply fail to do anything when its preferred action isn't possible.

### Example: Combat Weapon Selection

````
Selector
├── Sequence (Use Special Weapon)
│   ├── HasSpecialAmmo
│   └── FireSpecialWeapon
├── Sequence (Use Primary Weapon)
│   ├── HasPrimaryAmmo
│   └── FirePrimaryWeapon
└── MeleeAttack
````

In a first-person shooter, enemy soldiers will intelligently use their most powerful weapon when ammo is available, fall back to their standard rifle when special ammo is depleted, and resort to melee attacks when completely out of ammunition. This creates dynamic combat that evolves naturally as the fight progresses, rather than enemies that become harmless once their primary weapon is empty.

## Interrupt Pattern

This pattern allows a high-priority behavior to interrupt an ongoing behavior.

````
Selector
├── Sequence (High Priority Interrupt)
│   ├── InterruptCondition
│   └── InterruptAction
└── NormalBehavior
````

**Why it's useful:** Without interrupts, your AI would finish its current action before responding to urgent threats, looking robotic and unintelligent.

### Example: Dodge Incoming Attack

````
Selector
├── Sequence (Dodge)
│   ├── IsIncomingAttack
│   └── DodgeRoll
└── ContinueAttacking
````

In a souls-like game, enemy knights will interrupt their attack animations to dodge when the player launches a powerful attack, creating more dynamic and responsive combat where enemies react to the player's actions rather than mindlessly executing their attack patterns regardless of what's happening.
