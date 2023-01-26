# GdUnit generated TestSuite
class_name LimiterTest
extends GdUnitTestSuite
@warning_ignore(unused_parameter)
@warning_ignore(return_value_discarded)

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/limiter.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"
const __succeeder = "res://addons/beehave/nodes/decorators/succeeder.gd"

func test_max_count() -> void:
	var limiter = auto_free(load(__source).new())
	limiter.add_child(auto_free(load(__succeeder).new()))
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	limiter.max_count = 2
	assert_that(limiter.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(limiter.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(limiter.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
func test_max_count_reached_instantly() -> void:
	var limiter = auto_free(load(__source).new())
	limiter.add_child(auto_free(load(__succeeder).new()))
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	limiter.max_count = 0
	assert_that(limiter.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
