## Measures the cost of the built-in expression-based blackboard leaves
## in read-heavy, write-heavy and mixed access patterns.
extends "res://benchmark/bench.gd"


func title() -> String:
	return "Blackboard access patterns"


func benchmark_write_heavy() -> Dictionary:
	return tree_case(
		build(
			SequenceComposite,
			{},
			[
				_set_action("alpha", "1"),
				_set_action("beta", "2.0"),
				_set_action("gamma", '"value"'),
				_set_action("delta", "Vector2(1, 2)"),
			]
		)
	)


func benchmark_read_heavy() -> Dictionary:
	var case_config := tree_case(
		build(
			SequenceComposite,
			{},
			[
				_compare("alpha"),
				_compare("beta"),
				_has("alpha"),
				_has("beta"),
			]
		)
	)
	case_config.setup = func() -> void:
		case_config.tree.blackboard.set_value("alpha", 1)
		case_config.tree.blackboard.set_value("beta", 2)
	return case_config


func benchmark_mixed() -> Dictionary:
	return tree_case(
		build(
			SequenceComposite,
			{},
			[
				_set_action("alpha", "1"),
				_compare("alpha"),
				build(BlackboardEraseAction, {key = '"alpha"'}),
				_has("alpha"),
			]
		)
	)


func _set_action(key: String, value: String) -> Node:
	return build(BlackboardSetAction, {key = '"%s"' % key, value = value})


func _compare(key: String) -> Node:
	return build(
		BlackboardCompareCondition,
		{
			left_operand = 'get_value("%s")' % key,
			operator = BlackboardCompareCondition.Operators.GREATER_EQUAL,
			right_operand = "0",
		}
	)


func _has(key: String) -> Node:
	return build(BlackboardHasCondition, {key = '"%s"' % key})
