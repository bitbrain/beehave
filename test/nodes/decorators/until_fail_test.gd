# GdUnit generated TestSuite
class_name UntilFailDecoratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/until_fail.gd"
const __action = "res://test/actions/mock_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: MockAction
var until_fail: UntilFailDecorator


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	until_fail = auto_free(load(__source).new())

	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())

	tree.add_child(until_fail)
	until_fail.add_child(action)

	tree.actor = actor
	tree.blackboard = blackboard


func test_failure() -> void:
	action.final_result = BeehaveNode.RUNNING

	for i in range(100):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	action.final_result = BeehaveNode.SUCCESS

	for i in range(100):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	action.final_result = BeehaveNode.FAILURE
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

func test_after_run_called_on_success() -> void:
	action.final_result = BeehaveNode.SUCCESS
	
	# Child succeeds, decorator returns RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_true()

func test_after_run_called_on_failure() -> void:
	action.final_result = BeehaveNode.FAILURE
	
	# Child fails, decorator returns SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(action.after_run_called).is_true()

func test_after_run_not_called_during_running() -> void:
	action.final_result = BeehaveNode.RUNNING
	
	# Child is running, decorator returns RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_false()
	
	# Change to success, should call after_run
	action.final_result = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_true()
