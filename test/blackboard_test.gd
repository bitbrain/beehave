# GdUnit generated TestSuite
class_name BeehaveBlackboardTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

func test_has_value() -> void:
	var context := BeehaveContext.new() as BeehaveContext
	var blackboard = auto_free(BeehaveBlackboard.new())
	blackboard.set_value("my-key", 123)
	assert_bool(blackboard.has_value("my-key")).is_true()
	assert_bool(blackboard.has_value("my-key2")).is_false()
	
func test_erase_value() -> void:
	var blackboard = auto_free(BeehaveBlackboard.new())
	blackboard.set_value("my-key", 123)
	blackboard.erase_value("my-key")
	assert_bool(blackboard.has_value("my-key")).is_false()
	
func test_separate_blackboard_erase_value() -> void:
	var blackboard = auto_free(BeehaveBlackboard.new())
	blackboard.set_value("my-key", 123)
	blackboard.erase_value("my-key")
	assert_bool(blackboard.has_value("my-key")).is_false()

func test_set_value() -> void:
	var blackboard = auto_free(BeehaveBlackboard.new())
	blackboard.set_value("my-key", 123)
	assert_that(blackboard.get_value("my-key", null)).is_equal(123)
	
func test_get_default() -> void:
	var blackboard = auto_free(BeehaveBlackboard.new())
	blackboard.set_value("my-key", 123)
	assert_that(blackboard.get_value("my-key2", 234)).is_equal(234)
	
func test_blackboard_shared_between_trees() -> void:
	var scene = auto_free(load("res://test/unit_test_scene.tscn").instantiate())
	var runner = scene_runner(scene)
	
	await runner.simulate_frames(100)
	
	assert_that(scene.blackboard.get_value("c", null)).is_equal(4)
	assert_that(scene.blackboard.get_size()).is_equal(3)
