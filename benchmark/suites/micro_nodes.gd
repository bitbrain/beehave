## Measures the per-tick cost of every composite and decorator type.
## Composites are set up so that all children are traversed on every tick
## (sequences succeed, selectors fall through) to measure full traversal cost.
extends "res://benchmark/bench.gd"

const Leaves := preload("res://benchmark/leaves.gd")

const CHILDREN_COUNT := 4


func title() -> String:
	return "Per-node tick cost"


func benchmark_tree_with_single_action() -> Dictionary:
	return tree_case(_action(SUCCESS))


func benchmark_sequence() -> Dictionary:
	return tree_case(build(SequenceComposite, {}, _actions(SUCCESS)))


func benchmark_sequence_star() -> Dictionary:
	return tree_case(build(SequenceStarComposite, {}, _actions(SUCCESS)))


func benchmark_sequence_reactive() -> Dictionary:
	return tree_case(build(SequenceReactiveComposite, {}, _actions(SUCCESS)))


func benchmark_sequence_random() -> Dictionary:
	return tree_case(
		build(SequenceRandomComposite, {random_seed = RANDOM_SEED}, _actions(SUCCESS))
	)


func benchmark_selector() -> Dictionary:
	return tree_case(build(SelectorComposite, {}, _conditions(FAILURE)))


func benchmark_selector_reactive() -> Dictionary:
	return tree_case(build(SelectorReactiveComposite, {}, _conditions(FAILURE)))


func benchmark_selector_random() -> Dictionary:
	return tree_case(
		build(SelectorRandomComposite, {random_seed = RANDOM_SEED}, _conditions(FAILURE))
	)


func benchmark_simple_parallel() -> Dictionary:
	return tree_case(build(SimpleParallelComposite, {}, [_action(RUNNING), _action(SUCCESS)]))


func benchmark_inverter() -> Dictionary:
	return tree_case(build(InverterDecorator, {}, [_action(SUCCESS)]))


func benchmark_succeeder() -> Dictionary:
	return tree_case(build(AlwaysSucceedDecorator, {}, [_action(FAILURE)]))


func benchmark_failer() -> Dictionary:
	return tree_case(build(AlwaysFailDecorator, {}, [_action(SUCCESS)]))


func benchmark_repeater() -> Dictionary:
	return tree_case(build(RepeaterDecorator, {repetitions = 1}, [_action(SUCCESS)]))


func benchmark_until_fail() -> Dictionary:
	return tree_case(build(UntilFailDecorator, {}, [_action(FAILURE)]))


func benchmark_limiter() -> Dictionary:
	return tree_case(build(LimiterDecorator, {max_count = 1000000000}, [_action(SUCCESS)]))


func benchmark_cooldown() -> Dictionary:
	return tree_case(build(CooldownDecorator, {wait_time = 0.0}, [_action(SUCCESS)]))


func benchmark_delayer() -> Dictionary:
	return tree_case(build(DelayDecorator, {wait_time = 0.0}, [_action(SUCCESS)]))


func benchmark_time_limiter() -> Dictionary:
	return tree_case(build(TimeLimiterDecorator, {wait_time = 1000000000.0}, [_action(SUCCESS)]))


func _action(status: int) -> Node:
	return build(Leaves.Action, {status = status})


func _actions(status: int) -> Array:
	var result := []
	for i in CHILDREN_COUNT:
		result.append(_action(status))
	return result


func _conditions(status: int) -> Array:
	var result := []
	for i in CHILDREN_COUNT:
		result.append(build(Leaves.Condition, {status = status}))
	return result
