# GdUnit generated TestSuite
class_name TimeLimitTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/time_limiter.gd"
const __action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var action: BeehaveAction
var time_limiter: TimeLimiterDecorator
var actor: Node2D
var blackboard: BeehaveBlackboard
var runner:GdUnitSceneRunner


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.actor = actor
	tree.blackboard = blackboard
	action = auto_free(load(__action).new())
	time_limiter = auto_free(load(__source).new())
	
	time_limiter.add_child(action)
	tree.add_child(time_limiter)
	
	runner = scene_runner(tree)


func test_return_failure_when_child_exceeds_time_limiter() -> void:
	time_limiter.wait_time = 1.0
	action.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	await runner.simulate_frames(1, 1500)
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)


func test_reset_when_child_finishes() -> void:
	time_limiter.wait_time = 0.5
	action.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	await runner.simulate_frames(2, 500)
	action.status = BeehaveTreeNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)


func test_clear_running_child_after_run() -> void:
	time_limiter.wait_time = 1.5
	action.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(time_limiter.running_child).is_equal(action)
	action.status = BeehaveTreeNode.SUCCESS
	await runner.simulate_frames(1, 1600)
	assert_that(time_limiter.running_child).is_null()
