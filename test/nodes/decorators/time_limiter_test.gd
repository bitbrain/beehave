# GdUnit generated TestSuite
class_name TimeLimitTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/time_limiter.gd"
const __action = "res://test/actions/count_up_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: ActionLeaf
var time_limiter: TimeLimiterDecorator
var actor: Node2D
var blackboard: Blackboard
var runner:GdUnitSceneRunner


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())
	
	tree.actor = actor
	tree.blackboard = blackboard
	action = auto_free(load(__action).new())
	time_limiter = auto_free(load(__source).new())
	
	time_limiter.add_child(action)
	tree.add_child(time_limiter)
	
	runner = scene_runner(tree)


func test_return_failure_when_child_exceeds_time_limiter() -> void:
	time_limiter.wait_time = 0.3
	action.status = BeehaveNode.RUNNING
	await runner.simulate_frames(1, 10)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(5, 100)
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)


func test_reset_when_child_finishes() -> void:
	time_limiter.wait_time = 0.5
	action.status = BeehaveNode.RUNNING
	await runner.simulate_frames(1, 10)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(5, 100)
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)


func test_clear_running_child_after_run() -> void:
	time_limiter.wait_time = 0.1
	action.status = BeehaveNode.RUNNING
	await runner.simulate_frames(1)
	assert_that(time_limiter.running_child).is_equal(action)
	action.status = BeehaveNode.SUCCESS
	await runner.simulate_frames(1, 110)
	assert_that(time_limiter.running_child).is_null()
