# Sequence 
Sequence nodes will attempt to execute all of its children and reports `SUCCESS` status code in case all of the children report a `SUCCESS` status code. In case at least one child reports a `FAILURE` status code, this node will also return `FAILURE` status code. This node will attempt to process all its children every single tick, even if one of them is currently `RUNNING` already.

Type of Node | Child returns `FAILURE` | Child returns `RUNNING`
-- | -- | --
Sequence | Restart | Tick again
ReactiveSequence | Restart | Restart
SequenceStar | Tick again | Tick again

## Sequence Random
The Sequence Random will attempt to execute all of its children just like a Sequence Star would, with the exception that the children will be executed in a random order.