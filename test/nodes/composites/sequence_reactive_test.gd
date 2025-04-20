# GdUnit generated TestSuite
class_name SequenceReactiveTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/nodes/composites/sequence_reactive.gd"
const __count_up_action = "res://test/actions/count_up_action.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"

var tree: BeehaveTree
var action1: ActionLeaf
var action2: ActionLeaf
var actor: Node
var sequence: SequenceReactiveComposite
var blackboard: Blackboard


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action1 = auto_free(load(__count_up_action).new())
	action2 = auto_free(load(__count_up_action).new())
	sequence = auto_free(load(__source).new())
	actor = auto_free(Node2D.new())
	blackboard = auto_free(load(__blackboard).new())

	tree.add_child(sequence)
	sequence.add_child(action1)
	sequence.add_child(action2)

	tree.actor = actor
	tree.blackboard = blackboard


func test_always_exexuting_all_successful_nodes() -> void:
	var times_to_run = 2

	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveNode.SUCCESS)

	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(times_to_run)


func test_never_execute_second_when_first_is_failing() -> void:
	var times_to_run = 2
	action1.status = BeehaveNode.FAILURE

	for i in range(times_to_run):
		assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)

	assert_that(action1.count).is_equal(times_to_run)
	assert_that(action2.count).is_equal(0)


func test_keeps_running_child_until_success() -> void:
	action1.status = BeehaveNode.SUCCESS
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


func test_keeps_running_child_until_failure() -> void:
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.RUNNING

	for i in range(2):
		assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)

	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)

	action2.status = BeehaveNode.FAILURE

	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(3)
	assert_that(action2.count).is_equal(0)

	assert_that(tree.tick()).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(4)
	assert_that(action2.count).is_equal(1)


func test_restart_when_child_returns_failure() -> void:
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.FAILURE
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)


func test_restart_again_when_child_returns_running() -> void:
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.RUNNING
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(2)


func test_interrupt_second_when_first_is_running() -> void:
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)

	action1.status = BeehaveNode.RUNNING
	assert_that(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(2)
	assert_that(action2.count).is_equal(0)


func test_clear_running_child_after_run() -> void:
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.RUNNING
	tree.tick()
	assert_that(sequence.running_child).is_equal(action2)
	action2.status = BeehaveNode.SUCCESS
	tree.tick()
	assert_that(sequence.running_child).is_equal(null)


func test_branch_change_detection_on_failure() -> void:
	var action3 = auto_free(load(__count_up_action).new())
	sequence.add_child(action3)
	
	# First run: action3 fails - this will be remembered
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.SUCCESS
	action3.status = BeehaveNode.FAILURE
	
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	assert_that(action3.count).is_equal(1)
	
	# Make action3 RUNNING so we can detect interruption
	action3.status = BeehaveNode.RUNNING
	tree.tick()
	# Verify action3 is the running child
	assert_that(sequence.running_child).is_equal(action3)
	
	# Now action2 fails (earlier than action3) - should trigger branch change detection
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.FAILURE
	
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	# Check that running_child was reset due to the branch change
	assert_that(sequence.running_child).is_equal(null)
	
	sequence.remove_child(action3)
	
	

func test_nested_sequence_interrupt() -> void:
	# Create nested structure:
	# Root Sequence
	#  ├── Action1
	#  └── Child Sequence
	#       ├── Action2
	#       └── Action3
	
	var child_sequence = auto_free(load(__source).new())
	var action3 = auto_free(load(__count_up_action).new())
	
	# Remove action2 from root sequence and add it to child sequence
	sequence.remove_child(action2)
	child_sequence.add_child(action2)
	child_sequence.add_child(action3)
	sequence.add_child(child_sequence)
	
	# Set initial states (only action1 in RUNNING state)
	action1.status = BeehaveNode.RUNNING
	action2.status = BeehaveNode.SUCCESS
	action3.status = BeehaveNode.SUCCESS
	
	# First tick - action1 is running
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(0) # Not reached yet
	assert_that(action3.count).is_equal(0) # Not reached yet
	assert_that(sequence.running_child).is_equal(action1)
	
	# Second tick - action1 succeeds, action2 enters running state
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.RUNNING
	
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.RUNNING)
	assert_that(action1.count).is_equal(2) # success
	assert_that(action2.count).is_equal(1) # Now running
	assert_that(action3.count).is_equal(0) # Not reached yet
	assert_that(sequence.running_child).is_equal(child_sequence)
	assert_that(child_sequence.running_child).is_equal(action2)
	
	# Now we'll simulate a failure in action1 on next tick
	action1.status = BeehaveNode.FAILURE
	
	# Reset action2 count to clearly show interrupt effect
	action2.count = 0
	
	# Although action1 is failure, since action2 is still running tree is running
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
	# Verify that action2 was properly interrupted (count remains 0)
	assert_that(action1.count).is_equal(3) # Ticked again
	assert_that(action2.count).is_equal(0) # Never reached
	assert_that(action3.count).is_equal(0) # Never reached
	
	# Verify that running_child states are cleared
	assert_that(sequence.running_child).is_null()
	assert_that(child_sequence.running_child).is_null()


func test_nested_sequence_child_failure_interrupt() -> void:
	# Create nested structure:
	# Root Sequence
	#  ├── Action1
	#  └── Child Sequence
	#       ├── Action2
	#       └── Action3
	
	var child_sequence = auto_free(load(__source).new())
	var action3 = auto_free(load(__count_up_action).new())
	
	# Remove action2 from root sequence and add it to child sequence
	sequence.remove_child(action2)
	child_sequence.add_child(action2)
	child_sequence.add_child(action3)
	sequence.add_child(child_sequence)
	
	# Set all actions to success initially
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.SUCCESS
	action3.status = BeehaveNode.SUCCESS
	
	# First tick - all nodes succeed
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	assert_that(action3.count).is_equal(1)
	
	# Now make action2 fail
	action2.status = BeehaveNode.FAILURE
	# simulate that action3 needs interruption
	child_sequence.previous_failure_index = 1
	
	# Reset counts to better track execution
	action1.count = 0
	action2.count = 0
	action3.count = 0
	
	# Second tick - action2 fails, which should propagate failure upward
	# and interrupt action3
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	assert_that(action1.count).is_equal(1)
	assert_that(action2.count).is_equal(1)
	assert_that(action3.count).is_equal(0) # Should not be executed due to action2 failure
	
	# On the next tick, we should restart from action1
	action1.status = BeehaveNode.SUCCESS
	action2.status = BeehaveNode.SUCCESS
	
	# Action3 got interrupted, so tree reports failure!
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.FAILURE)
	
	action3.status = BeehaveNode.SUCCESS
	
	# Reset counts again
	action1.count = 0
	action2.count = 0
	action3.count = 0
	
	assert_that(sequence.tick(actor, blackboard)).is_equal(BeehaveNode.SUCCESS)
	assert_that(action1.count).is_equal(1) # Should execute again
	assert_that(action2.count).is_equal(1) # Should execute again
	assert_that(action3.count).is_equal(1) # Should execute again
