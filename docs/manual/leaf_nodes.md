# Leaf Nodes

Leaf nodes are the core elements of Behavior Trees, responsible for executing actions and evaluating conditions for your game characters or objects. Unlike composite or decorator nodes, leaf nodes are positioned at the ends of branches in the tree structure and do not have any children. They serve as the endpoints of the tree, where actual game behaviors are determined and performed.

## Purpose of Leaf Nodes

While composite nodes are responsible for controlling the flow of execution and connecting different nodes together, leaf nodes focus on carrying out specific actions or assessing certain conditions. Leaf nodes allow you to define the essential behaviors and decisions that your game characters or objects will make, based on the overall logic of the Behavior Tree.

By combining leaf nodes with composite and decorator nodes, you can create a hierarchical structure that is capable of producing complex, context-dependent behaviors for your game characters or objects. The leaf nodes ensure that the tree's logic ultimately results in tangible actions or condition checks, bringing the AI to life and providing engaging gameplay experiences.

## `tick` Method Example

Here's an example of how to use these methods in an `ActionLeaf`:

The `tick` method is the main method of the node that is called every time the behavior tree is ticked. It should contain the custom logic for the node and return a status code:
```gdscript
class_name MoveToTargetAction extends ActionLeaf

var target: NodePath

func _init(target: NodePath):
	self.target = target

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_node = blackboard.get_node(self.target)
	if target_node == null:
		return FAILURE

	actor.look_at(target_node.global_position)
	actor.move_and_slide(actor.global_transform.basis.z * 10, Vector3.UP)

	if actor.global_transform.origin.distance_to(target_node.global_position) < 2:
		return SUCCESS

	return RUNNING

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	actor.stop()
```
In this example, the `MoveToTargetAction` is an `ActionLeaf` that moves the actor towards a specified target node. The `tick` function is called every frame and moves the actor until it reaches the target. If the actor is within 2 units of distance to the target, `SUCCESS` is returned. If the action is interrupted, the `interrupt` function is called and the actor is stopped.

## `interrupt` Method Example

This method is called when a running node needs to be interrupted before it can return `FAILURE` or `SUCCESS`. You can use this method to cancel any ongoing actions:

```gdscript
func interrupt(actor: Node, blackboard: Blackboard) -> void:
    # Let's say we have an ActionLeaf called "CastSpell" that takes in a spell name
    spell_name = "fireball"
    action_node = CastSpell.new(spell_name)
    
    # If the action is currently running, call its interrupt method
    if action_node.get_status() == RUNNING:
        action_node.interrupt(actor, blackboard)
```

## `before_run` Method Example

This method is called before the first time the node is ticked by its parent. You can use this method to set up any necessary state before the node's logic is executed:

```gdscript
func before_run(actor: Node, blackboard: Blackboard) -> void:
    # Let's say we have an ActionLeaf called "EquipItem" that takes in an item name
    item_name = "enchanted sword"
    action_node = EquipItem.new(item_name)
    
    # Print a message to the console
    print(actor.name + " equipping " + item_name + "...")
    
    # Execute the action and return the status code
    action_node.tick(actor, blackboard)
```

## `after_run` Method Example

This method is called after the last time the node is ticked and returns either `SUCCESS` or `FAILURE`. You can use this method to perform any cleanup or reset any state that was set up in the `before_run` method:

```gdscript
func after_run(actor: Node, blackboard: Blackboard) -> void:
    # Let's say we have an ActionLeaf called "GainExperience" that takes in an amount of experience
    exp_gained = 100
    action_node = GainExperience.new(exp_gained)
    
    # Print a message to the console
    print(actor.name + " gained " + str(exp_gained) + " experience points!")
    
    # Execute the action
    action_node.tick(actor, blackboard)
```