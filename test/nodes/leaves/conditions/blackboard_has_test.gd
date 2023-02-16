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


func before_test() -> void:
	blackboard_has = auto_free(load(__source).new())
	actor = null
	blackboard = auto_free(load(__blackboard).new())
	blackboard_has.key = "\"%s\"" % [KEY]
	runner = scene_runner(blackboard_has)


func test_key_exists() -> void:
	blackboard.set_value(KEY, 0)
	assert_that(blackboard_has.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)


func test_key_exists_but_value_null() -> void:
	blackboard.set_value(KEY, null)
	assert_that(blackboard_has.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)


func test_key_does_not_exist() -> void:
	assert_that(blackboard_has.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)


func test_invalid_key_expression() -> void:
	blackboard_has.key = "this is invalid!!!"
	assert_that(blackboard_has.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
