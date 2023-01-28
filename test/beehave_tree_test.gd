# GdUnit generated TestSuite
class_name BeehaveTreeTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/beehave_tree.gd"

func create_scene() -> Node2D:
	return auto_free(load("res://test/UnitTestScene.tscn").instantiate())

	
func test_nothing_running_before_first_tick() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_null()
	assert_that(scene.beehave_tree.get_last_condition_status()).is_equal("")
	
func test_get_last_condition() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree._physics_process(1.0)
	assert_that(scene.beehave_tree.get_running_action()).is_null()
	assert_that(scene.beehave_tree.get_last_condition()).is_not_null()
	assert_that(scene.beehave_tree.get_last_condition_status()).is_equal("FAILURE")
	
func test_disabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	assert_bool(scene.beehave_tree.enabled).is_false()
	

func test_reenabled() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	scene.beehave_tree.disable()
	scene.beehave_tree.enable()
	assert_bool(scene.beehave_tree.enabled).is_true()
