# GdUnit generated TestSuite
class_name CooldownDecoratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/beehave/nodes/decorators/cooldown.gd'
const __action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var action: BeehaveAction
var cooldown: CooldownDecorator
var runner:GdUnitSceneRunner

func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action = auto_free(load(__action).new())
	cooldown = auto_free(load(__source).new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(cooldown)
	cooldown.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard
	runner = scene_runner(tree)

func test_running_then_fail() -> void:
	cooldown.wait_time = 1.0
	action.status = BeehaveTreeNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	action.status = BeehaveTreeNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	action.status = BeehaveTreeNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	await runner.simulate_frames(1, 2000)
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
