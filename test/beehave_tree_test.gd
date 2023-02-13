# GdUnit generated TestSuite
class_name BeehaveTreeTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/beehave_tree.gd"

func create_scene() -> Node2D:
	return auto_free(load("res://test/UnitTestScene.tscn").instantiate())
	

func test_normal_tick() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.status).is_equal(BeehaveNode.SUCCESS)

	
func test_nothing_running_before_first_tick() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_null()
	assert_that(scene.beehave_tree.get_last_condition_status()).is_equal("")
	
func test_get_last_condition() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	await runner.simulate_frames(10)
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_not_null()
	assert_that(scene.beehave_tree.get_last_condition_status()).is_equal('SUCCESS')
	
func test_disabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	await runner.simulate_frames(10)
	assert_bool(scene.beehave_tree.enabled).is_false()
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_null()
	

func test_reenabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	scene.beehave_tree.enable()
	await runner.simulate_frames(10)
	assert_bool(scene.beehave_tree.enabled).is_true()
	assert_that(scene.beehave_tree.get_last_condition()).is_not_null()
	
	
func test_interrupt_running_action() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.count_up_action.status = BeehaveNode.RUNNING
	scene.beehave_tree._physics_process(1.0)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(2)
	scene.beehave_tree.interrupt()
	assert_that(scene.beehave_tree.blackboard.get_value("custom_value")).is_equal(0)
	assert_that(scene.count_up_action.status).is_equal(BeehaveNode.FAILURE)
