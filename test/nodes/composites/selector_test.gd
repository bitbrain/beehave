# GdUnit generated TestSuite
class_name SelectorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/selector.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"
const __selector_reactive = "res://addons/beehave/nodes/composites/selector_reactive.gd"

var tree: BeehaveTree
var selector: SelectorComposite
var action1: ActionLeaf
var action2: ActionLeaf
var actor: Node
var blackboard: Blackboard


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	selector = auto_free(load(__source).new())
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(selector)
	selector.add_child(action1)
	selector.add_child(action2)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_always_executing_first_successful_node() -> void:
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)


func test_execute_second_when_first_is_failing() -> void:
	action1.status = BeehaveNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_return_failure_of_none_is_succeeding() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)


func test_not_interrupt_second_when_first_is_succeeding() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	
	action1.status = BeehaveNode.SUCCESS
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_not_interrupt_second_when_first_is_running() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	
	action1.status = BeehaveNode.RUNNING
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_tick_again_when_child_returns_running() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(2)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	tree.tick()
	assert_that(selector.running_child).is_equal(action2)
	action2.status = BeehaveNode.FAILURE
	tree.tick()
	assert_that(selector.running_child).is_equal(null)


func test_not_interrupt_first_after_finished() -> void:
	var action3 = auto_free(load(__count_up_action).new())
	selector.add_child(action3)
	var running_action: Node
	var blackboard_name: String = str(actor.get_instance_id())

	action1.status = BeehaveNode.RUNNING
	action2.status = BeehaveNode.FAILURE
	action3.status = BeehaveNode.RUNNING

	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(0)
	assert_that(action3.count).is_equal(0)
	
	action1.status = BeehaveNode.FAILURE
	assert_that(selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(1)
	assert_that(action3.count).is_equal(1)
	
	selector.remove_child(action3)


func test_interrupt_when_nested() -> void:
	var selector_reactive = auto_free(load(__selector_reactive).new())
	var fake_condition = auto_free(load(__count_up_action).new())
	
	tree.remove_child(selector)
	tree.add_child(selector_reactive)
	selector_reactive.add_child(fake_condition)
	selector_reactive.add_child(selector)
	
	fake_condition.status = BeehaveNode.FAILURE
	action1.status = BeehaveNode.RUNNING
	
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(0)
	
	fake_condition.status = BeehaveNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(0)
	assert_that(action2.count).is_equal(0)
	
	# clean up...
	selector_reactive.remove_child(selector)
	tree.remove_child(selector_reactive)
	tree.add_child(selector)
