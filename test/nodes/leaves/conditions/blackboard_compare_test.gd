# GdUnit generated TestSuite
class_name BeehaveBlackboardCompareConditionTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/leaves/blackboard_compare.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"


var blackboard_compare: BeehaveBlackboardCompareCondition
var actor: Node
var blackboard: BeehaveBlackboard

var runner: GdUnitSceneRunner


func before_test() -> void:
	blackboard_compare = auto_free(load(__source).new())
	actor = null
	blackboard = auto_free(load(__blackboard).new())


func test_comparison_operators() -> void:
	var data: Dictionary = {
		["0", "0"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveTreeNode.SUCCESS],
		],
		["0", "1"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveTreeNode.SUCCESS],
		],
		["1", "0"]: [
			[BlackboardCompareCondition.Operators.EQUAL, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.NOT_EQUAL, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.GREATER, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS, BeehaveTreeNode.FAILURE],
			[BlackboardCompareCondition.Operators.GREATER_EQUAL, BeehaveTreeNode.SUCCESS],
			[BlackboardCompareCondition.Operators.LESS_EQUAL, BeehaveTreeNode.FAILURE],
		]
	}
	
	for operands in data:
		for pair in data[operands]:
			blackboard_compare = auto_free(load(__source).new())
			
			var operator: BeehaveBlackboardCompareCondition.Operators = pair[0]
			var expected_status: int = pair[1]
			
			blackboard_compare.left_operand = operands[0]
			blackboard_compare.right_operand = operands[1]
			blackboard_compare.operator = operator
			
			runner = scene_runner(blackboard_compare)
			
			assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(expected_status)


func test_blackboard_access() -> void:
	blackboard.set_value("direction", Vector3.FORWARD)
	
	blackboard_compare.left_operand = "get_value(\"direction\").length()"
	blackboard_compare.operator = BeehaveBlackboardCompareCondition.Operators.EQUAL
	blackboard_compare.right_operand = "1"
	
	runner = scene_runner(blackboard_compare)
	assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)


func test_invalid_left_operand_expression() -> void:
	blackboard_compare.left_operand = "this is invalid!!!"
	blackboard_compare.operator = BeehaveBlackboardCompareCondition.Operators.EQUAL
	blackboard_compare.right_operand = "1"
	
	runner = scene_runner(blackboard_compare)
	assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)


func test_invalid_right_operand_expression() -> void:
	blackboard_compare.left_operand = "1"
	blackboard_compare.operator = BeehaveBlackboardCompareCondition.Operators.EQUAL
	blackboard_compare.right_operand = "this is invalid!!!"
	
	runner = scene_runner(blackboard_compare)
	assert_that(blackboard_compare.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
