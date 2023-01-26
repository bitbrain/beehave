# GdUnit generated TestSuite
class_name BeehaveTreeTest
extends GdUnitTestSuite
@warning_ignore(unused_parameter)
@warning_ignore(return_value_discarded)

# TestSuite generated from
const __source = "res://addons/beehave/beehave_tree.gd"
	
func test_no_action_running_before_first_tick() -> void:
	var runner := scene_runner("res://test/UnitTestScene.tscn")
	assert_that(null).is_null()
