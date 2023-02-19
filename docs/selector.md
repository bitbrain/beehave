# Selector
Selector nodes will attempt to execute each of its children and reports `SUCCESS` status code in case one of the children reports a `SUCCESS` status code. In case all children report a `FAILURE` status code, this node will also return `FAILURE` status code. This node will attempt to process all its children every single tick, even if one of them is currently `RUNNING` already.

## Selector Star (Selector Reactive)
The Selector Star node is similar to the Selector, however, it will skip all previous child nodes that were executed prior, in case one of the children is currently in RUNNING state. A usecase for this is if you want to ensure that only one action is executed at a time, regardless of for long it runs.

## Selector Random
The Selector Random will attempt to execute all of its children just like a Selector Star would, with the exception that the children will be executed in a random order.
