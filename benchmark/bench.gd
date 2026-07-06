## Base class for benchmark suites. Each suite lives in `benchmark/suites/`
## and defines one `benchmark_<name>()` method per case, returning a case
## dictionary created via one of the `*_case()` helpers below.
extends Node

enum { SUCCESS, FAILURE, RUNNING }

const RANDOM_SEED := 1234

const DEFAULTS := {
	warmup = 500,
	batches = 50,
	batch_size = 200,
	per_frame = false,
	relative_to = "",
	unit = "µs/tick",
	unit_divisor = 1.0,
}


## Human readable suite title used in reports and charts.
func title() -> String:
	return get_script().resource_path.get_file().get_basename()


## Instantiates a node of the given type, assigns the given fields and
## adds the given children to it.
func build(type: Variant, fields: Dictionary = {}, children: Array = []) -> Node:
	var result: Node = type.new()
	for field in fields:
		result.set(field, fields[field])
	for child in children:
		result.add_child(child)
	return result


## A case that repeatedly ticks a manually processed behavior tree
## with the given root node.
func tree_case(root: Node, overrides: Dictionary = {}) -> Dictionary:
	var actor := Node.new()
	var tree: BeehaveTree = build(
		BeehaveTree, {process_thread = BeehaveTree.ProcessThread.MANUAL}, [root]
	)
	actor.add_child(tree)
	var result := DEFAULTS.duplicate()
	result.merge({node = actor, tree = tree, workload = tree.tick}, true)
	result.merge(overrides, true)
	return result


## A case that repeatedly invokes a raw GDScript workload.
func code_case(workload: Callable, overrides: Dictionary = {}) -> Dictionary:
	var result := DEFAULTS.duplicate()
	result.merge({node = null, workload = workload, unit = "µs/call"}, true)
	result.merge(overrides, true)
	return result


## A case that mounts a custom node into the scene and repeatedly
## invokes the given workload.
func scene_case(mount: Node, workload: Callable, overrides: Dictionary = {}) -> Dictionary:
	var result := DEFAULTS.duplicate()
	result.merge({node = mount, workload = workload}, true)
	result.merge(overrides, true)
	return result
