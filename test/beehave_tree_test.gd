# GdUnit generated TestSuite
class_name BeehaveTreeTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/beehave_tree.gd"


func create_scene() -> Node2D:
	return auto_free(load("res://test/unit_test_scene.tscn").instantiate())


func create_tree() -> BeehaveTree:
	return auto_free(load(__source).new())


func test_normal_tick() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.status).is_equal(BeehaveNode.SUCCESS)


func test_low_tick_rate() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.tick_rate = 3
	assert_that(scene.beehave_tree.status).is_equal(-1)
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.status).is_equal(0)
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.status).is_equal(0)
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.status).is_equal(BeehaveNode.SUCCESS)


func test_low_tick_rate_last_tick() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.tick_rate = 3
	scene.beehave_tree.last_tick = 1
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.status).is_equal(-1)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.status).is_equal(BeehaveNode.SUCCESS)


func test_nothing_running_before_first_tick() -> void:
	var scene = create_scene()
	scene_runner(scene)
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_null()
	assert_that(scene.beehave_tree.get_last_condition_status()).is_equal("")


func test_get_last_condition() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	await runner.simulate_frames(100)
	assert_that(scene.beehave_tree_without_interrupt.get_running_action()).is_null()
	assert_that(scene.beehave_tree_without_interrupt.get_last_condition()).is_not_null()
	assert_that(scene.beehave_tree_without_interrupt.get_last_condition_status()).is_equal("SUCCESS")


func test_disabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	await runner.simulate_frames(50)
	assert_bool(scene.beehave_tree.enabled).is_false()
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_null()


func test_reenabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	scene.beehave_tree.enable()
	await runner.simulate_frames(50)
	assert_bool(scene.beehave_tree.enabled).is_true()
	assert_that(scene.beehave_tree.get_last_condition()).is_not_null()


func test_interrupt_running_action() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree._physics_process(1.0)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(2)
	scene.beehave_tree.interrupt()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(0)
	assert_that(scene.count_up_action.status).is_equal(BeehaveNode.FAILURE)


func test_blackboard_not_initialized() -> void:
	var tree = create_tree()
	tree.actor = auto_free(Node2D.new())
	var always_succeed = auto_free(AlwaysSucceedDecorator.new()) as AlwaysSucceedDecorator
	always_succeed.add_child(auto_free(ActionLeaf.new()))
	tree.add_child(always_succeed)
	var result = tree.tick()
	assert_that(result).is_equal(BeehaveNode.SUCCESS)


func test_actor_override() -> void:
	var scene = create_scene()
	scene_runner(scene)
	var tree = create_tree()
	var actor = auto_free(Node2D.new())
	tree.actor = actor
	scene.add_child(tree)
	assert_that(tree.actor).is_equal(actor)


func test_manual_mode_does_not_auto_tick() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	scene.beehave_tree.enabled = true
	
	# Set up count up action
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree.blackboard.set_value("custom_value", 0)
	
	# Wait a bit to verify no auto-ticks
	await get_tree().create_timer(0.1).timeout
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(0)


func test_manual_mode_can_tick_manually() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	scene.beehave_tree.enabled = true
	
	# Set up count up action
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree.blackboard.set_value("custom_value", 0)
	
	# Manual tick should increase counter
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)
	
	# Another manual tick should increase counter again
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(2)


func test_manual_mode_respects_tick_rate() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	scene.beehave_tree.tick_rate = 3
	scene.beehave_tree.enabled = true
	
	# Set up count up action
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree.blackboard.set_value("custom_value", 0)
	
	# First tick should increase counter
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)
	
	# Second tick should not yet increase counter 
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)
	
	# Second tick should not yet increase counter 
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)
	
	# Fourth tick should increase counter
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(2)


func test_manual_mode_can_be_disabled() -> void:
	var scene = create_scene()
	scene_runner(scene)
	scene.beehave_tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	scene.beehave_tree.enabled = true
	
	# Set up count up action
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree.blackboard.set_value("custom_value", 0)
	
	# Should be able to tick when enabled
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)
	
	# Disable the tree
	scene.beehave_tree.disable()
	
	# Should not be able to tick when disabled
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(1)  # Value should not change
	
	# Re-enable the tree
	scene.beehave_tree.enable()
	
	# Should be able to tick again
	scene.beehave_tree.tick()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(2)
