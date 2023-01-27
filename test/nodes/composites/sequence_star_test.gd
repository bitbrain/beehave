# GdUnit generated TestSuite
class_name SequenceStarTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/sequence_star.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"

var sequence:SequenceStarComposite
var action1:ActionLeaf
var action2:ActionLeaf
var actor:Node
var blackboard:Blackboard

func before_test() -> void:
	sequence = auto_free(load(__source).new())
	action1 = auto_free(load(__count_up_action).new())
	sequence.add_child(action1)
	action2 = auto_free(load(__count_up_action).new())
	sequence.add_child(action2)
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())

func test_always_exexuting_all_successful_nodes() -> void:
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)
	
func test_never_execute_second_when_first_is_failing() -> void:
	action1.status = BeehaveNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)
	
func test_keeps_running_child_until_success() -> void:
	action2.status = BeehaveNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)
	action2.status = BeehaveNode.SUCCESS
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(3)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(4)
	
func test_keeps_running_child_until_failure() -> void:
	action2.status = BeehaveNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)
	action2.status = BeehaveNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(3)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(4)
	
