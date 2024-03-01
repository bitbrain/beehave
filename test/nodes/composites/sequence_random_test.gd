# GdUnit generated TestSuite
class_name SequenceRandomTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/sequence_random.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const RANDOM_SEED = 123

var tree: BeehaveTree
var sequence: SequenceRandomComposite
var action1: BeehaveAction
var action2: BeehaveAction


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action1 = auto_free(load(__count_up_action).new())
	action1.name = 'Action 1'
	action2 = auto_free(load(__count_up_action).new())
	action2.name = 'Action 2'
	sequence = auto_free(load(__source).new())
	sequence.random_seed = RANDOM_SEED
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(sequence)
	sequence.add_child(action1)
	sequence.add_child(action2)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_always_executing_first_successful_node() -> void:
	var times_to_run = 2
	
	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	
	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(times_to_run)
	
func test_execute_second_when_first_is_failing() -> void:
	var times_to_run = 2
	action1.status = BeehaveTreeNode.FAILURE
	
	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(1)


func test_random_even_execution() -> void:
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action2.count).is_equal(2)


func test_weighted_random_sampling() -> void:
	sequence.use_weights = true
	sequence._weights[action1.name] = 2
	assert_dict(sequence._weights).contains_key_value(action1.name, 2)
	assert_dict(sequence._weights).contains_key_value(action2.name, 1)
	
	action1.status = BeehaveTreeNode.RUNNING
	action2.status = BeehaveTreeNode.RUNNING
	
	assert_array(sequence._children_bag).is_empty()
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	
	# Children are in reverse order; aka action1 will run first.
	assert_array(sequence._children_bag)\
			.contains_exactly([action2, action1])
	
	# Only action 1 should have executed.
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(0)
	
	action1.status = BeehaveTreeNode.SUCCESS
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(1)
	
	sequence.use_weights = false


func test_return_failure_of_none_is_succeeding() -> void:
	action1.status = BeehaveTreeNode.FAILURE
	action2.status = BeehaveTreeNode.FAILURE
	
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)
	
	assert_that(action1.count).is_equal(0)
	assert_that(action2.count).is_equal(1)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveTreeNode.SUCCESS
	action2.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(sequence.running_child).is_equal(action2)
	action2.status = BeehaveTreeNode.SUCCESS
	tree.tick()
	assert_that(sequence.running_child).is_equal(null)
