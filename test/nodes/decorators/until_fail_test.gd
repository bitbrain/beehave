# GdUnit generated TestSuite
class_name UntilFailDecoratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/beehave/nodes/decorators/until_fail.gd'
const __action = "res://test/actions/count_up_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: ActionLeaf
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
	action.status = BeehaveNode.RUNNING
	
	for i in range(100):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	action.status = BeehaveNode.SUCCESS
	
	for i in range(100):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	action.status = BeehaveNode.FAILURE
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
