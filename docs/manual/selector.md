# Selector
Selector nodes will attempt to execute each of its children and reports `SUCCESS` status code in case one of the children reports a `SUCCESS` status code. In case all children report a `FAILURE` status code, this node will also return `FAILURE` status code. This node will attempt to process all its children every single tick, even if one of them is currently `RUNNING` already.

Type of Node | Child returns `RUNNING`
-- | --
`SelectorComposite` | Restart
`SelectorReactiveComposite` | Tick again

## Selector Random
The `SelectorRandomComposite` will attempt to execute all of its children just like a Selector Star would, with the exception that the children will be executed in a random order.
