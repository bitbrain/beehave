# GdUnit generated TestSuite
class_name LimiterTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

const __action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var action: BeehaveAction
var limiter: BeehaveLimiter


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action = auto_free(load(__action).new())
	limiter = auto_free(BeehaveLimiter.new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(limiter)
	limiter.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_max_count(count: int, _test_parameters: Array = [[2], [0]]) -> void:
	limiter.max_count = count
	action.status = BeehaveTreeNode.RUNNING
	for i in range(count):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)

	assert_that(action.count).is_equal(count)
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	# ensure it resets its child after it reached max count
	assert_that(action.count).is_equal(0)
	

#func test_interrupt_after_run() -> void:
#	action.status = BeehaveTreeNode.RUNNING
#	limiter.max_count = 1
#	tree.tick()
#	assert_that(limiter.running_child).is_equal(action)
#	action.status = BeehaveTreeNode.FAILURE
#	tree.tick()
#	assert_that(action.count).is_equal(0)
#	assert_that(limiter.running_child).is_equal(null)


#func test_clear_running_child_after_run() -> void:
#	action.status = BeehaveTreeNode.RUNNING
#	limiter.max_count = 10
#	tree.tick()
#	assert_that(limiter.running_child).is_equal(action)
#	action.status = BeehaveTreeNode.SUCCESS
#	tree.tick()
#	assert_that(action.count).is_equal(2)
#	assert_that(limiter.running_child).is_equal(null)
