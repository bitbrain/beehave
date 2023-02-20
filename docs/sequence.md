# Sequence 
Sequence nodes will attempt to execute all of its children and reports `SUCCESS` status code in case all of the children report a `SUCCESS` status code. In case at least one child reports a `FAILURE` status code, this node will also return `FAILURE` status code. This node will attempt to process all its children every single tick, even if one of them is currently `RUNNING` already.

## Sequence Star (Sequence Reactive)
The Sequence Star node is similar to the Sequence, however, it will skip all previous child nodes that succeeded prior, in case one of the children is currently in RUNNING state. A usecase for this is if you want to ensure that only one action is executed at a time, regardless of for long it runs.

## Sequence Random
The Sequence Random will attempt to execute all of its children just like a Sequence Star would, with the exception that the children will be executed in a random order.
