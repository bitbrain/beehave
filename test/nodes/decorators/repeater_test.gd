# GdUnit generated TestSuite
class_name RepeaterTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/repeater.gd"
const __action = "res://test/actions/mock_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: MockAction
var repeater: RepeaterDecorator


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	repeater = auto_free(load(__source).new())

	# action setup
	action.running_frame_count = 3 # runs for 3 frames
	action.started_running.connect(_on_action_started)
	action.stopped_running.connect(_on_action_ended)
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(repeater)
	repeater.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func after_test():
	# resets blackboard
	tree.blackboard.set_value("started", 0)
	tree.blackboard.set_value("ended", 0)


func test_repetitions(count: int, test_parameters: Array = [[2], [0]]) -> void:
	repeater.repetitions = count
	action.final_result = BeehaveNode.SUCCESS

	var frames_to_run = count * (action.running_frame_count + 1)

	# It should return `RUNNING` every frame but the last one.
	for i in range(frames_to_run - 1):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	
	var times_started = tree.blackboard.get_value("started", 0)
	var times_ended = tree.blackboard.get_value("ended", 0)

	assert_int(times_started).is_equal(count)
	assert_int(times_ended).is_equal(count)


func test_failure():
	repeater.repetitions = 2
	action.final_result = BeehaveNode.SUCCESS

	for i in range(action.running_frame_count + 1):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	# it should have started and ended normally
	var times_started = tree.blackboard.get_value("started", 0)
	var times_ended = tree.blackboard.get_value("ended", 0)

	assert_int(times_started).is_equal(1)
	assert_int(times_ended).is_equal(1)

	action.final_result = BeehaveNode.FAILURE

	for i in range(action.running_frame_count):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)

	times_started = tree.blackboard.get_value("started", 0)
	times_ended = tree.blackboard.get_value("ended", 0)

	assert_int(times_started).is_equal(2)
	assert_int(times_ended).is_equal(2)


func _on_action_started(actor, blackboard):
	var started = blackboard.get_value("started", 0)
	blackboard.set_value("started", started + 1)


func _on_action_ended(actor, blackboard):
	var ended = blackboard.get_value("ended", 0)
	blackboard.set_value("ended", ended + 1)
