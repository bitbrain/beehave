## Measures total AI cost per frame for a realistic 13-node
## patrol/chase/attack behavior tree (the industry-standard benchmark
## scenario) instantiated on an increasing number of agents.
## Agents deterministically cycle through all three branches: enemy
## visibility flips periodically, chasing closes the distance over
## multiple frames and attacking resets it.
extends "res://benchmark/bench.gd"

const AGENT_COUNTS := [1, 10, 100, 500, 1000]
const VISIBILITY_PERIOD := 120


class VisibilityCondition extends ConditionLeaf:
	var offset: int = 0

	func tick(_actor: Node, _blackboard: Blackboard) -> int:
		var phase := (Engine.get_process_frames() + offset) / VISIBILITY_PERIOD
		return SUCCESS if phase % 2 == 1 else FAILURE


class ChaseAction extends ActionLeaf:
	func tick(_actor: Node, blackboard: Blackboard) -> int:
		var distance: int = blackboard.get_value("distance", 20) - 1
		blackboard.set_value("distance", distance)
		return SUCCESS if distance <= 2 else RUNNING


class AttackAction extends ActionLeaf:
	func tick(_actor: Node, blackboard: Blackboard) -> int:
		blackboard.set_value("distance", 20)
		return SUCCESS


class PatrolAction extends ActionLeaf:
	var ticks: int = 0

	func tick(_actor: Node, _blackboard: Blackboard) -> int:
		ticks += 1
		if ticks >= 45:
			ticks = 0
			return SUCCESS
		return RUNNING


func title() -> String:
	return "Agent scaling (patrol/chase/attack)"


func benchmark_agents() -> Array:
	var cases := []
	for count in AGENT_COUNTS:
		cases.append(_agents_case(count))
	return cases


func _agents_case(count: int) -> Dictionary:
	var mount := Node.new()
	var trees: Array[BeehaveTree] = []
	for i in count:
		var actor := Node.new()
		var tree: BeehaveTree = build(
			BeehaveTree, {process_thread = BeehaveTree.ProcessThread.MANUAL}, [_agent_tree(i)]
		)
		actor.add_child(tree)
		mount.add_child(actor)
		trees.append(tree)
	var case_config := scene_case(
		mount,
		_tick_agents.bind(trees),
		{
			name = "%d agent%s" % [count, "" if count == 1 else "s"],
			warmup = 60,
			batches = 240,
			batch_size = 1,
			per_frame = true,
			unit = "ms/frame",
			unit_divisor = 1000.0,
		}
	)
	case_config.setup = func() -> void:
		for tree in trees:
			tree.blackboard.set_value("waypoint", Vector2.ONE)
			tree.blackboard.set_value("distance", 20)
	return case_config


func _agent_tree(agent_index: int) -> Node:
	return build(
		SelectorComposite,
		{},
		[
			build(
				SequenceComposite,
				{name = "Attack"},
				[
					build(VisibilityCondition, {offset = agent_index}),
					build(
						BlackboardCompareCondition,
						{
							left_operand = 'get_value("distance")',
							operator = BlackboardCompareCondition.Operators.LESS_EQUAL,
							right_operand = "2",
						}
					),
					AttackAction.new(),
				]
			),
			build(
				SequenceComposite,
				{name = "Chase"},
				[
					build(VisibilityCondition, {offset = agent_index}),
					ChaseAction.new(),
				]
			),
			build(
				SequenceComposite,
				{name = "Patrol"},
				[
					build(BlackboardHasCondition, {key = '"waypoint"'}),
					PatrolAction.new(),
				]
			),
		]
	)


func _tick_agents(trees: Array[BeehaveTree]) -> void:
	for tree in trees:
		tree.tick()
