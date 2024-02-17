# GdUnit generated TestSuite
class_name SequenceStarTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/sequence_star.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var action1: BeehaveAction
var action2: BeehaveAction
var actor: Node
var blackboard: BeehaveBlackboard
var sequence: SequenceStarComposite


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	sequence = auto_free(load(__source).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(sequence)
	sequence.add_child(action1)
	sequence.add_child(action2)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_always_exexuting_all_successful_nodes() -> void:
	var times_to_run = 2
	
	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	
	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(times_to_run)


func test_never_execute_second_when_first_is_failing() -> void:
	var times_to_run = 2
	action1.status = BeehaveTreeNode.FAILURE
	
	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	
	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(0)


func test_keeps_running_child_until_success() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	
	for i in range(2):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)
	
	action2.status = BeehaveTreeNode.SUCCESS
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(3)
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(4)


func test_keeps_running_child_until_failure() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	
	for i in range(2):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)
	
	action2.status = BeehaveTreeNode.FAILURE
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	# action2 will reset as it failed
	assert_that(action2.count).is_equal(0)
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	# action2 has reset previously but sequence star will tick again
	assert_that(action2.count).is_equal(1)


func test_tick_again_when_child_returns_failure() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(1)
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
