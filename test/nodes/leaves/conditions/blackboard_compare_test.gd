# GdUnit generated TestSuite
class_name BlackboardCompareConditionTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/leaves/blackboard_compare.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"


var blackboard_compare: BlackboardCompareCondition
var actor: Node
var blackboard: Blackboard

var runner: GdUnitSceneRunner


func before_test() -> void:
	blackboard_compare = auto_free(load(__source).new())
	actor = null
	blackboard = auto_free(load(__blackboard).new())


func test_comparison_operators() -> void:
	var data: Dictionary = {
		["0", "0"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveNode.SUCCESS],
		],
		["0", "1"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveNode.SUCCESS],
		],
		["1", "0"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS, BeehaveNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveNode.FAILURE],
		]
	}
	
	for operands in data:
		for pair in data[operands]:
			blackboard_compare = auto_free(load(__source).new())
			
			var operator: BlackboardCompareCondition.Operators = pair[0]
			var expected_status: int = pair[1]
			
			blackboard_compare.left_operand = operands[0]
			blackboard_compare.right_operand = operands[1]
			blackboard_compare.operator = operator
			
			runner = scene_runner(blackboard_compare)
			
			assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(expected_status)


func test_blackboard_access() -> void:
	blackboard.set_value("direction", Vector3.FORWARD)
	
	blackboard_compare.left_operand = "get_value(\"direction\").length()"
	blackboard_compare.operator = BlackboardCompareCondition.Operators.EQUAL
	blackboard_compare.right_operand = "1"
	
	runner = scene_runner(blackboard_compare)
	assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
