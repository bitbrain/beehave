# GdUnit generated TestSuite
class_name LimiterTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/limiter.gd"
const __action = "res://test/actions/count_up_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: ActionLeaf
var limiter: LimiterDecorator


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	limiter = auto_free(load(__source).new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(limiter)
	limiter.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_max_count(count: int, test_parameters: Array = [[2], [0]]) -> void:
	limiter.max_count = count

	for i in range(count):
		assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

	assert_that(action.count).is_equal(count)
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	

func test_interrupt_after_run() -> void:
	action.status = BeehaveNode.RUNNING
	limiter.max_count = 1
	tree.tick()
	assert_that(limiter.running_child).is_equal(action)
	action.status = BeehaveNode.FAILURE
	tree.tick()
	assert_that(action.count).is_equal(0)
	assert_that(limiter.running_child).is_equal(null)


func test_clear_running_child_after_run() -> void:
	action.status = BeehaveNode.RUNNING
	limiter.max_count = 10
	tree.tick()
	assert_that(limiter.running_child).is_equal(action)
	action.status = BeehaveNode.SUCCESS
	tree.tick()
	assert_that(action.count).is_equal(2)
	assert_that(limiter.running_child).is_equal(null)
