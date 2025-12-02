# GdUnit generated TestSuite
class_name CooldownDecoratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/cooldown.gd"
const __action = "res://test/actions/mock_action.gd"
const __composite = "res://test/composites/mock_composite.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var tree: BeehaveTree
var action: MockAction
var composite: MockComposite
var cooldown: CooldownDecorator
var runner: GdUnitSceneRunner


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__action).new())
	composite = auto_free(load(__composite).new())
	cooldown = auto_free(load(__source).new())

	# action setup
	action.interrupted.connect(_on_interrupted)

	# composite setup
	composite.interrupted.connect(_on_interrupted)

	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())

	tree.add_child(cooldown)
	cooldown.add_child(action)

	tree.actor = actor
	tree.blackboard = blackboard
	runner = scene_runner(tree)


func after_test():
	# resets blackboard
	tree.blackboard.set_value("interrupted", 0)


func test_running_then_fail() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	action.final_result = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	action.final_result = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	await runner.simulate_frames(20, 100)
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)


func test_interrupt_propagates_when_actionleaf() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.RUNNING
	tree.tick()
	tree.interrupt()

	var times_interrupted = tree.blackboard.get_value("interrupted", 0)
	assert_that(times_interrupted).is_equal(1)


func test_interrupt_propagates_when_composite() -> void:
	cooldown.remove_child(action)
	cooldown.add_child(composite)

	cooldown.wait_time = 1.0
	composite.final_result = BeehaveNode.RUNNING
	tree.tick()
	tree.interrupt()

	var times_interrupted = tree.blackboard.get_value("interrupted", 0)
	assert_that(times_interrupted).is_equal(1)


func _on_interrupted(_actor, blackboard):
	var started = blackboard.get_value("interrupted", 0)
	blackboard.set_value("interrupted", started + 1)

func test_after_run_called_on_success() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should execute child and call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(action.after_run_called).is_true()
	
	# Reset after_run_called flag so we can detect future calls
	action.after_run_called = false
	
	# Second tick should be in cooldown and not call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_bool(action.after_run_called).is_false()

func test_after_run_called_on_failure() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.FAILURE
	
	# First tick should execute child and call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_bool(action.after_run_called).is_true()
	
	# Reset after_run_called flag so we can detect future calls
	action.after_run_called = false
	
	# Second tick should be in cooldown and not call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_bool(action.after_run_called).is_false()

func test_after_run_not_called_during_cooldown() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should execute child and call after_run
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(action.after_run_called).is_true()
	
	# Reset after_run_called flag so we can detect future calls
	action.after_run_called = false
	
	# Wait a bit but not enough to complete cooldown
	await runner.simulate_frames(1, 500)
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_bool(action.after_run_called).is_false()  # Should not call after_run during cooldown

func test_before_run_only_called_once_per_cooldown() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	assert_that(action.before_run_call_count).is_equal(0)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action.before_run_call_count).is_equal(1)
	
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_that(action.before_run_call_count).is_equal(1)
	
	var cache_key := "cooldown_%s" % cooldown.get_instance_id()
	var actor_id := str(tree.actor.get_instance_id())
	# Manually expire the cooldown to avoid depending on wall-clock time in tests
	tree.blackboard.set_value(cache_key, Time.get_ticks_msec() - 1.0, actor_id)
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action.before_run_call_count).is_equal(2)

func test_cooldown_reset_on_interrupt() -> void:
	cooldown.wait_time = 1.0
	action.final_result = BeehaveNode.SUCCESS
	
	# First tick should execute child and start cooldown
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	
	# Second tick should be in cooldown
	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	
	# Interrupt should reset the cooldown
	tree.interrupt()
	
	# After interrupt, the cooldown should be reset and the action should execute normally
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
