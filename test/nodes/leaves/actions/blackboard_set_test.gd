# GdUnit generated TestSuite
class_name BlackboardSetActionTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = "res://addons/beehave/nodes/leaves/blackboard_set.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"


const KEY: String = "test_key"
const KEY2: String = "other_key"

var blackboard_set: BlackboardSetAction
var actor: Node
var blackboard: Blackboard


func before_test() -> void:
	blackboard_set = auto_free(load(__source).new())
	actor = null
	blackboard = auto_free(load(__blackboard).new())
	blackboard_set.key = "\"%s\"" % [KEY]


func test_set_to_constant() -> void:
	blackboard_set.value = "0"
	scene_runner(blackboard_set) # run it as a scene, so that _ready gets called
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_bool(blackboard.has_value(KEY)).is_true()
	assert_that(blackboard.get_value(KEY)).is_equal(0)


func test_copy_key() -> void:
	blackboard.set_value(KEY2, 0)
	blackboard_set.value = "get_value('%s')" % [KEY2]
	scene_runner(blackboard_set)
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(blackboard.get_value(KEY)).is_equal(blackboard.get_value(KEY2)) # properly copy values from one key to another


func test_invalid_expression() -> void:
	blackboard_set.value = "this is not a valid expression"
	scene_runner(blackboard_set)
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_bool(blackboard.has_value(KEY)).is_false()


func test_set_vector3() -> void:
	blackboard_set.value = "Vector3(0,0,0)"
	scene_runner(blackboard_set)
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_bool(blackboard.has_value(KEY)).is_true()
	assert_that(blackboard.get_value(KEY)).is_equal(Vector3(0,0,0))


func test_invalid_key_expression() -> void:
	blackboard_set.key = "this is invalid!!!"
	scene_runner(blackboard_set)
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)


func test_invalid_value_expression() -> void:
	blackboard_set.value = "this is invalid!!!"
	scene_runner(blackboard_set)
	assert_that(blackboard_set.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
