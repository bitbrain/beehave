# GdUnit generated TestSuite
class_name TimeLimitTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/time_limit.gd"
const __action = "res://test/actions/count_up_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: ActionLeaf
var time_limit: TimeLimitDecorator


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	time_limit = auto_free(load(__source).new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(time_limit)
	time_limit.child = action
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_return_failure_when_child_exceeds_time_limit() -> void:
	time_limit.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	time_limit.time_left = 0.5
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	time_limit.time_left = 1.0
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)


func test_reset_when_child_finishes() -> void:
	time_limit.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	time_limit.time_left = 0.5
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)


func test_clear_running_child_after_run() -> void:
	time_limit.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	tree.tick()
	assert_that(time_limit.running_child).is_equal(action)
	action.status = BeehaveNode.SUCCESS
	tree.tick()
	assert_that(time_limit.running_child).is_equal(null)
