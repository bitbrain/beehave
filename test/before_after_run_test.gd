class_name BeforeAfterRunTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const __mock_action = "res://test/actions/mock_action.gd"
const __succedeer = "res://addons/beehave/nodes/decorators/succeeder.gd"
const __blackboard = "res://addons/beehave/blackboard.gd"
const __tree = "res://addons/beehave/nodes/beehave_tree.gd"

var tree: BeehaveTree
var action: ActionLeaf


func before_test() -> void:
	tree = auto_free(load(__tree).new())
	action = auto_free(load(__mock_action).new())
	var succeeder = auto_free(load(__succedeer).new())
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(load(__blackboard).new())
	
	tree.add_child(succeeder)
	succeeder.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_action_after_run() -> void:
	var before_run_callback = func (actor, blackboard):
		blackboard.set_value("entered", true)
	
	var after_run_callback = func (actor, blackboard):
		blackboard.set_value("exited", true)
	
	action.started_running.connect(before_run_callback)
	action.stopped_running.connect(after_run_callback)
	action.running_frame_count = 1
	
	assert_bool(tree.blackboard.get_value("entered", false)).is_false()
	assert_bool(tree.blackboard.get_value("exited", false)).is_false()
	
	assert_int(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(tree.blackboard.get_value("entered", false)).is_true()
	assert_bool(tree.blackboard.get_value("exited", false)).is_false()
	
	assert_int(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(tree.blackboard.get_value("entered", false)).is_true()
	assert_bool(tree.blackboard.get_value("exited", false)).is_true()
