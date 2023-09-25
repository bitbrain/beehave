# GdUnit generated TestSuite
class_name BlackboardEraseActionTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/leaves/blackboard_erase.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

const KEY: String = "test_key"

var blackboard_erase: BlackboardEraseAction
var actor: Node
var blackboard: Blackboard
var delta: float # Default delta so it can run 

var runner: GdUnitSceneRunner


func before_test() -> void:
	blackboard_erase = auto_free(load(__source).new())
	blackboard_erase.key = "\"%s\"" % [KEY]
	actor = null
	blackboard = auto_free(load(__blackboard).new())


func test_erase_existing_key() -> void:
	blackboard.set_value(KEY, 0)
	
	runner = scene_runner(blackboard_erase)
	assert_that(blackboard_erase.tick(actor, blackboard, delta)).is_equal(BeehaveNode.SUCCESS)


func test_erase_non_existing_key() -> void:
	runner = scene_runner(blackboard_erase)
	assert_that(blackboard_erase.tick(actor, blackboard, delta)).is_equal(BeehaveNode.SUCCESS)


func test_invalid_key_expression() -> void:
	blackboard_erase.key = "this is invalid!!!"
	
	runner = scene_runner(blackboard_erase)
	assert_that(blackboard_erase.tick(actor, blackboard, delta)).is_equal(BeehaveNode.FAILURE)
