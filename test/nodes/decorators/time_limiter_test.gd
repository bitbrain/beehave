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


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	time_limiter = auto_free(load(__source).new())
	
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(time_limiter)
	time_limiter.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_return_failure_when_child_exceeds_time_limiter() -> void:
	time_limiter.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	blackboard.set_value(time_limiter.cache_key, 0.5, str(actor.get_instance_id()))
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	blackboard.set_value(time_limiter.cache_key, 1.0, str(actor.get_instance_id()))
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)


func test_reset_when_child_finishes() -> void:
	time_limiter.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	blackboard.set_value(time_limiter.cache_key, 0.5, str(actor.get_instance_id()))
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)


func test_clear_running_child_after_run() -> void:
	time_limiter.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	tree.tick()
	assert_that(time_limiter.running_child).is_equal(action)
	action.status = BeehaveNode.SUCCESS
	tree.tick()
	assert_that(time_limiter.running_child).is_equal(null)
