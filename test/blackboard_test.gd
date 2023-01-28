# GdUnit generated TestSuite
class_name BlackboardTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/blackboard.gd"

func test_has_value() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123)
	assert_bool(blackboard.has_value("my-key")).is_true()
	assert_bool(blackboard.has_value("my-key2")).is_false()
	
func test_erase_value() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123)
	blackboard.erase_value("my-key")
	assert_bool(blackboard.has_value("my-key")).is_false()
	
func test_separate_blackboard_erase_value() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123, "other-blackboard")
	blackboard.erase_value("my-key", "other-blackboard")
	assert_bool(blackboard.has_value("my-key", "other-blackboard")).is_false()

func test_set_value() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123)
	assert_that(blackboard.get_value("my-key")).is_equal(123)
	
func test_separate_blackboard_id_value() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123)
	blackboard.set_value("my-key", 234, "other-blackboard")
	assert_that(blackboard.get_value("my-key")).is_equal(123)
	assert_that(blackboard.get_value("my-key", null, "other-blackboard")).is_equal(234)
	
func test_get_default() -> void:
	var blackboard = auto_free(load(__source).new())
	blackboard.set_value("my-key", 123)
	assert_that(blackboard.get_value("my-key2", 234)).is_equal(234)
	
func test_blackboard_shared_between_trees() -> void:
	var scene = auto_free(load("res://test/UnitTestScene.tscn").instantiate())
	var runner = scene_runner(scene)
	
	await runner.simulate_frames(10)
	
	assert_that(scene.blackboard.get_value("custom_value")).is_equal(4)
	assert_that(scene.blackboard.get_value("custom_value")).is_equal(4)
	assert_that(scene.blackboard.keys().size()).is_equal(3)
