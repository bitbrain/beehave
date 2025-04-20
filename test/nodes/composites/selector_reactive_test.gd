# GdUnit generated TestSuite
class_name SelectorReactiveTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/selector_reactive.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"

var tree: BeehaveTree
var selector: SelectorReactiveComposite
var action1: ActionLeaf
var action2: ActionLeaf
var actor:Node
var blackboard:Blackboard


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	tree.process_thread = BeehaveTree.ProcessThread.MANUAL
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	selector = auto_free(load(__source).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())

	tree.add_child(selector)
	selector.add_child(action1)
	selector.add_child(action2)

	tree.actor = actor
	tree.blackboard = blackboard


func test_always_executing_first_successful_node() -> void:
	var times_to_run = 2

	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(0)


func test_execute_second_when_first_is_failing() -> void:
	var times_to_run = 2

	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.SUCCESS

	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(times_to_run)


func test_return_failure_of_none_is_succeeding() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.FAILURE

	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)

	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)


func test_keeps_restarting_child_until_success() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING

	for i in range(2):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)

	action2.status = BeehaveNode.SUCCESS

	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(3)
	assert_that(action2.count).is_equal(3)

	assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(4)
	assert_that(action2.count).is_equal(4)


func test_keeps_restarting_child_until_failure() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING

	for i in range(2):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)

	action2.status = BeehaveNode.FAILURE

	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(3)
	assert_that(action2.count).is_equal(3)

	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(4)
	assert_that(action2.count).is_equal(4)


func test_interrupt_second_when_first_is_running() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)

	action1.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.RUNNING
	tree.tick()
	assert_that(selector.running_child).is_equal(action2)
	action2.status = BeehaveNode.FAILURE
	tree.tick()
	assert_that(selector.running_child).is_equal(null)


func test_branch_change_detection() -> void:
	var action3 = auto_free(load(__count_up_action).new())
	
	# Add three actions to test branch changes
	selector.add_child(action3)   # index 2
	
	# Initial conditions - make action3 succeed first
	action1.status = BeehaveNode.FAILURE
	action2.status = BeehaveNode.FAILURE
	action3.status = BeehaveNode.SUCCESS
	
	# First tick - establish initial success at index 2
	tree.tick()
	assert_that(selector.previous_success_or_running_index).is_equal(2)
	
	# Now make action2 succeed while action3 fails
	action2.status = BeehaveNode.SUCCESS
	action3.status = BeehaveNode.FAILURE
	
	# Tick to establish new success at index 1
	tree.tick()
	assert_that(selector.previous_success_or_running_index).is_equal(1)
	
	# Now make action1 succeed - this causes a branch change from index 1 to index 0
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.FAILURE
	
	# This should change the success index
	tree.tick()
	assert_that(selector.previous_success_or_running_index).is_equal(0)
	
	

	
	
func test_complex_nested_selector_interruption() -> void:
	# Create a complex tree with multiple nested selectors
	var root_selector = auto_free(load(__source).new())
	var branch1_selector = auto_free(load(__source).new())
	var branch2_selector = auto_free(load(__source).new())
	
	var branch1_action1 = auto_free(load(__count_up_action).new())
	var branch1_action2 = auto_free(load(__count_up_action).new())
	var branch2_action1 = auto_free(load(__count_up_action).new())
	var branch2_action2 = auto_free(load(__count_up_action).new())
	
	# Structure:
	# root_selector
	#  ├── branch1_selector
	#  │    ├── branch1_action1 (FAILURE)
	#  │    └── branch1_action2 (RUNNING)
	#  └── branch2_selector
	#       ├── branch2_action1 (FAILURE)
	#       └── branch2_action2 (SUCCESS)
	
	root_selector.add_child(branch1_selector)
	root_selector.add_child(branch2_selector)
	
	branch1_selector.add_child(branch1_action1)
	branch1_selector.add_child(branch1_action2)
	
	branch2_selector.add_child(branch2_action1)
	branch2_selector.add_child(branch2_action2)
	
	# Set initial states
	branch1_action1.status = BeehaveNode.FAILURE
	branch1_action2.status = BeehaveNode.RUNNING
	branch2_action1.status = BeehaveNode.FAILURE
	branch2_action2.status = BeehaveNode.SUCCESS
	
	# First tick to establish running state in branch1
	assert_that(root_selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	
	# Verify the correct path is running
	assert_that(root_selector.running_child).is_equal(branch1_selector)
	assert_that(branch1_selector.running_child).is_equal(branch1_action2)
	assert_that(branch1_action1.count).is_equal(1)
	assert_that(branch1_action2.count).is_equal(1)
	assert_that(branch2_action1.count).is_equal(0)
	assert_that(branch2_action2.count).is_equal(0)
	
	# Interrupt the root selector
	root_selector.interrupt(actor, blackboard)
	
	# Verify all running state was cleared
	assert_that(root_selector.running_child).is_equal(null)
	assert_that(branch1_selector.running_child).is_equal(null)
	assert_that(branch1_action2.count).is_equal(0) # Reset by interruption
	
	# Start a different branch running and verify proper state reset
	branch1_action1.status = BeehaveNode.RUNNING
	branch1_action2.status = BeehaveNode.FAILURE
	
	# Tick again to establish a new running state
	assert_that(root_selector.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	
	# Verify new running path
	assert_that(root_selector.running_child).is_equal(branch1_selector)
	assert_that(branch1_selector.running_child).is_equal(branch1_action1)
	assert_that(branch1_action1.count).is_equal(1)
	
	# Interrupt again
	root_selector.interrupt(actor, blackboard)
	
	# Verify everything is interrupted again
	assert_that(root_selector.running_child).is_equal(null)
	assert_that(branch1_selector.running_child).is_equal(null)
	assert_that(branch1_action1.count).is_equal(0) # Reset by interruption

func test_interrupt_all_children_after_all_failed() -> void:
	# Create a selector with multiple actions
	var root_selector = auto_free(load(__source).new())
	var action_a = auto_free(load(__count_up_action).new())
	var action_b = auto_free(load(__count_up_action).new())
	var action_c = auto_free(load(__count_up_action).new())
	
	# Set up reset_on_interrupt to track interruptions
	action_a.reset_on_interrupt = true
	action_b.reset_on_interrupt = true
	action_c.reset_on_interrupt = true
	
	root_selector.add_child(action_a)
	root_selector.add_child(action_b)
	root_selector.add_child(action_c)
	
	# Configure all actions to fail
	action_a.status = BeehaveNode.FAILURE
	action_b.status = BeehaveNode.FAILURE
	action_c.status = BeehaveNode.FAILURE
	
	# First tick - all children should be ticked and report FAILURE
	assert_that(root_selector.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
	# Verify all actions were ticked once
	assert_that(action_a.count).is_equal(1)
	assert_that(action_b.count).is_equal(1)
	assert_that(action_c.count).is_equal(1)
	
	# Interrupt the selector - this should interrupt all children
	root_selector.interrupt(actor, blackboard)
	
	# Verify all children were interrupted (count reset to 0)
	assert_that(action_a.count).is_equal(0)
	assert_that(action_b.count).is_equal(0)
	assert_that(action_c.count).is_equal(0)
	
	# Restore counts for second test
	action_a.count = 1
	action_b.count = 1
	action_c.count = 1
	
	# Interrupt again - this should NOT interrupt children again
	# because they've already been interrupted once
	root_selector.interrupt(actor, blackboard)
	
	# Counts should remain unchanged from the previous step
	assert_that(action_a.count).is_equal(1)
	assert_that(action_b.count).is_equal(1)
	assert_that(action_c.count).is_equal(1)
	
	# Tick again to verify normal operation resumes
	assert_that(root_selector.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
	# Counts should be incremented because we ticked again
	assert_that(action_a.count).is_equal(2)
	assert_that(action_b.count).is_equal(2)
	assert_that(action_c.count).is_equal(2)


func test_nested_interrupt_after_all_failed() -> void:
	# Create a more complex structure to test nested interrupt behavior
	var parent_selector = auto_free(load(__source).new())
	var child_selector = auto_free(load(__source).new())
	var action_a = auto_free(load(__count_up_action).new())
	var action_b = auto_free(load(__count_up_action).new())
	var action_c = auto_free(load(__count_up_action).new())
	
	# Set up structure:
	# parent_selector
	#   ├── action_a
	#   └── child_selector
	#         ├── action_b
	#         └── action_c
	
	parent_selector.add_child(action_a)
	parent_selector.add_child(child_selector)
	child_selector.add_child(action_b)
	child_selector.add_child(action_c)
	
	# Set up all actions to fail
	action_a.status = BeehaveNode.FAILURE
	action_b.status = BeehaveNode.FAILURE
	action_c.status = BeehaveNode.FAILURE
	
	# Tick the parent - all nodes should be ticked and report FAILURE
	assert_that(parent_selector.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
	# Verify all actions were ticked
	assert_that(action_a.count).is_equal(1)
	assert_that(action_b.count).is_equal(1)
	assert_that(action_c.count).is_equal(1)
	
	# Interrupt the parent selector
	parent_selector.interrupt(actor, blackboard)
	
	# Verify all children were interrupted properly
	assert_that(action_a.count).is_equal(0)
	assert_that(action_b.count).is_equal(0)
	assert_that(action_c.count).is_equal(0)
	
	# Restore counts for next test
	action_a.count = 1
	action_b.count = 1
	action_c.count = 1
	
	# Now interrupt the parent again - shouldn't interrupt children twice
	parent_selector.interrupt(actor, blackboard)
	
	# Values should remain unchanged from previous step
	assert_that(action_a.count).is_equal(1)
	assert_that(action_b.count).is_equal(1)
	assert_that(action_c.count).is_equal(1)
	
	# Next tick should reset all back to normal operation
	action_a.status = BeehaveNode.FAILURE
	action_b.status = BeehaveNode.SUCCESS
	
	assert_that(parent_selector.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action_a.count).is_equal(2)
	assert_that(action_b.count).is_equal(2)
	assert_that(action_c.count).is_equal(1) # Shouldn't be ticked since b succeeds
