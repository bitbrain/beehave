# Simple Parallel

The Simple Parallel node is a fundamental building block in Behavior Trees, used to execute two children at the same time. It helps you run multiple actions simultaneously. Think of the Simple Parallel node as "While doing A, do B as well".

## How does it work?
Simple Parallel nodes will attempt to execute all children at the same time and can only have exactly two children. First child as the primary node, second child as the secondary node.
This node will always report the primary node's state, and continue ticking while the primary node returns `RUNNING`. The state of the secondary node will be ignored and executed like a subtree.
If the primary node returns `SUCCESS` or `FAILURE`, this node will interrupt the secondary node and return the primary node's result.
If this node is running under delay mode, it will wait for the secondary node to finish its action after the primary node terminates.


## Example Scenarios
Here are some example scenarios to help you understand the Sequence node better:

### Example: While attacking the enemy, move toward the enemy
Imagine you want a ranged enemy character trying to shoot you whenever they can while moving towards you. You can use a Simple Parallel node with the following child nodes architecture:

1. Move to player
2. Sequence Node
   1. Check if enemy can shoot
   2. Shoot

The enemy will move to the player and try to shoot at the same time. If the move action is successful or fails, the Simple Parallel node will terminate the child sequence node for the shooting attempt, then return `SUCCESS` or `FAILURE` according to the move action result.

<ul style="list-style: none;">
    <li>
        <img src="assets/icons/tree.svg" width="18px"/>
        BeehaveTree
    </li>
    <li>
        <ul style="list-style: none;">
            <li>
                <a href="#/manual/simple_parallel"><img src="/beehave/assets/icons/simple_parallel.svg" width="18px"/></a>
                SimpleParallel
            </li>
            <li>
                <ul style="list-style: none;">
                    <li>
                        <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                        MoveToPlayer
                    </li>
                    <li>
                        <a href="#/manual/sequence?id=sequence-node"><img src="assets/icons/sequence.svg" width="18px"/></a>
                        SequenceComposite
                    </li>
                    <li>
                        <ul style="list-style: none;">
                            <li>
                                <a href="#/manual/condition_leaf?id=condition-leaf"><img src="assets/icons/condition.svg" width="18px"/></a>
                                CanShoot
                            </li>
                            <li>
                                <a href="#/manual/action_leaf?id=action-leaf-node"><img src="assets/icons/action.svg" width="18px"/></a>
                                Shoot
                            </li>
                        </ul>
                    </li>
                </ul>
            </li>
        </ul>
    </li>
</ul>

Although Simple Parallel can be nested to create complex behaviors, it is not recommended, as too much nesting may make it difficult to maintain your behavior tree.
