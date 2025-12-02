# GdUnit generated TestSuite
class_name DelayDecoratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/delayer.gd"
const __action = "res://test/actions/mock_action.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: MockAction
var delayer: DelayDecorator
var runner: GdUnitSceneRunner


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
	delayer.wait_time = get_physics_process_delta_time()
	action.final_result = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	# Assure that the delayer properly resets
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)


func test_return_running_after_delay() -> void:
	delayer.wait_time = 1.0
	action.final_result = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, 1000)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	action.final_result = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	# Assure that the delayer properly resets
	action.final_result = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	await runner.simulate_frames(1, 1000)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	action.final_result = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

func test_after_run_called_on_success() -> void:
	delayer.wait_time = get_physics_process_delta_time()
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should be in delay
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_false()
	
	# Second tick should execute child and call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(action.after_run_called).is_true()

func test_after_run_called_on_failure() -> void:
	delayer.wait_time = get_physics_process_delta_time()
	action.final_result = BeehaveNode.FAILURE
	
	# First tick should be in delay
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_false()
	
	# Second tick should execute child and call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_bool(action.after_run_called).is_true()

func test_after_run_not_called_during_delay() -> void:
	delayer.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should be in delay
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_false()
	
	# Wait a bit but not enough to complete delay
	await runner.simulate_frames(1, 500)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(action.after_run_called).is_false()

func test_before_run_only_called_once_per_run() -> void:
	delayer.wait_time = get_physics_process_delta_time() * 2.0
	action.final_result = BeehaveNode.SUCCESS
	
	assert_that(action.before_run_call_count).is_equal(0)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action.before_run_call_count).is_equal(0)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action.before_run_call_count).is_equal(0)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action.before_run_call_count).is_equal(1)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action.before_run_call_count).is_equal(1)

	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action.before_run_call_count).is_equal(1)

	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action.before_run_call_count).is_equal(2)

func test_delay_reset_on_interrupt() -> void:
	delayer.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should start the delay
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	# Simulate partial progress through the delay
	await runner.simulate_frames(1, 500)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	# Interrupt should reset the delay
	tree.interrupt()
	
	# Verify the blackboard value is reset
	var cache_key = "time_limiter_%s" % delayer.get_instance_id()
	var blackboard_value = tree.blackboard.get_value(cache_key, -1, str(tree.actor.get_instance_id()))
	assert_that(blackboard_value).is_equal(0.0) # This should pass if our reset works
	
	# First tick after interrupt should start a new delay from the beginning
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	
	# Set running_child to null to force a reinitialize on next tick
	# This simulates what would happen in a real tree when switching branches
	delayer.running_child = null
	
	# Manually "complete" the delay by setting it past the wait time
	cache_key = "time_limiter_%s" % delayer.get_instance_id()
	tree.blackboard.set_value(cache_key, 1.1, str(tree.actor.get_instance_id()))  # Set it past wait_time
	
	# Now when we tick, it should execute the child and return SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
