# GdUnit generated TestSuite
class_name SelectorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/selector.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var selector:SelectorComposite
var action1:ActionLeaf
var action2:ActionLeaf
var actor:Node
var blackboard:Blackboard

func before_test() -> void:
	selector = auto_free(load(__source).new())
	action1 = auto_free(load(__count_up_action).new())
	selector.add_child(action1)
	action2 = auto_free(load(__count_up_action).new())
	selector.add_child(action2)
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())

func test_always_executing_first_successful_node() -> void:
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)
	
func test_execute_second_when_first_is_failing() -> void:
	action1.status = BeehaveNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)
	
func test_return_failure_of_none_is_succeeding() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	
	
