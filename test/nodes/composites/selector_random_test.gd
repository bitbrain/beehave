# GdUnit generated TestSuite
class_name SelectorRandomTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/selector_random.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const RANDOM_SEED = 123

var tree: BeehaveTree
var selector: SelectorRandomComposite
var action1: BeehaveAction
var action2: BeehaveAction
var actor: Node
var blackboard: BeehaveBlackboard


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	selector = auto_free(load(__source).new())
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(selector)
	selector.add_child(action1)
	selector.add_child(action2)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_always_executing_first_successful_node() -> void:
	selector.random_seed = RANDOM_SEED
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)


func test_execute_second_when_first_is_failing() -> void:
	selector.random_seed = RANDOM_SEED
	action2.status = BeehaveTreeNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action2.count).is_equal(1)
	assert_that(action1.count).is_equal(2)


func test_random_even_execution() -> void:
	selector.random_seed = RANDOM_SEED
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action2.count).is_equal(1)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.SUCCESS)
	assert_that(action1.count).is_equal(1)


func test_return_failure_of_none_is_succeeding() -> void:
	selector.random_seed = RANDOM_SEED
	action1.status = BeehaveTreeNode.FAILURE
	action2.status = BeehaveTreeNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveTreeNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveTreeNode.FAILURE
	action2.status = BeehaveTreeNode.RUNNING
	tree.tick()
	assert_that(selector.running_child).is_equal(action2)
	action2.status = BeehaveTreeNode.FAILURE
	tree.tick()
	assert_that(selector.running_child).is_equal(null)
