# GdUnit generated TestSuite
class_name DelayDecoratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/beehave/nodes/decorators/delayer.gd'
const __action = "res://test/actions/count_up_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: ActionLeaf
var delayer: DelayDecorator
var runner:GdUnitSceneRunner

func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	delayer = auto_free(load(__source).new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(delayer)
	delayer.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard
	runner = scene_runner(tree)

func test_return_success_after_delay() -> void:
	var delta_time = get_physics_process_delta_time()
	delayer.wait_time = delta_time
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, delta_time)
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	# Assure that the delayer properly resets
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, delta_time)
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

func test_return_running_after_delay() -> void:
	delayer.wait_time = 1.0
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, 1000)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	# Assure that the delayer properly resets
	action.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, 1000)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	action.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
