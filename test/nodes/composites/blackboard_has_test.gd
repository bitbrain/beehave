# GdUnit generated TestSuite
class_name BlackboardHasConditionTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = "res://addons/beehave/nodes/leaves/blackboard_has.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"


const KEY: String = "test_key"

var blackboard_has: BlackboardHasCondition
var actor: Node
var blackboard: Blackboard

var runner: GdUnitSceneRunner
var delta: float # Default delta so it can run 

func before_test() -> void:
	blackboard_has = auto_free(load(__source).new())
	actor = null
	blackboard = auto_free(load(__blackboard).new())
	blackboard_has.key = "\"%s\"" % [KEY]


func test_key_exists() -> void:
	blackboard.set_value(KEY, 0)
	
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.SUCCESS)


func test_variant_key_exists() -> void:
	blackboard.set_value(Vector2(0, 0), 0)
	blackboard_has.key = "Vector2(0, 0)"
	
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.SUCCESS)


func test_key_exists_but_value_null() -> void:
	blackboard.set_value(KEY, null)
	
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.FAILURE)


func test_key_does_not_exist() -> void:
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.FAILURE)


func test_invalid_key_expression() -> void:
	blackboard_has.key = "this is invalid!!!"
	
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.FAILURE)


func test_invalid_key_expression_wrong_format() -> void:
	blackboard_has.key = KEY
	
	runner = scene_runner(blackboard_has)
	assert_that(blackboard_has.tick(actor, blackboard, delta)).is_equal(BeehaveNode.FAILURE)
