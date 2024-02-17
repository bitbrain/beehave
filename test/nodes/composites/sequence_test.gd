# GdUnit generated TestSuite
class_name SequenceTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/sequence.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var sequence: SequenceComposite
var action1: BeehaveAction
var action2: BeehaveAction
var actor: Node
var blackboard: BeehaveBlackboard


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	sequence = auto_free(load(__source).new())
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(sequence)
	sequence.add_child(action1)
	sequence.add_child(action2)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_always_executing_all_successful_nodes() -> void:
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)


func test_never_execute_second_when_first_is_failing() -> void:
	action1.status = BeehaveTreeNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)


func test_not_interrupt_second_when_first_is_failing() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	
	action1.status = BeehaveTreeNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_not_interrupting_second_when_first_is_running() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	
	action1.status = BeehaveTreeNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_restart_when_child_returns_failure() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)
	
func test_tick_again_when_child_returns_running() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(sequence.running_child).is_equal(action2)
	action2.status = BeehaveTreeNode.SUCCESS
	tree.tick()
	assert_that(sequence.running_child).is_equal(null)


func test_not_interrupt_first_after_finished() -> void:
	var action3 = auto_free(load(__count_up_action).new())
	sequence.add_child(action3)

	action1.status = BeehaveTreeNode.RUNNING
	action2.status = BeehaveTreeNode.SUCCESS
	action3.status = BeehaveTreeNode.RUNNING

	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(0)
	assert_that(action3.count).is_equal(0)
	
	action1.status = BeehaveTreeNode.SUCCESS
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.RUNNING)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(1)
	assert_that(action3.count).is_equal(1)
	
	sequence.remove_child(action3)
