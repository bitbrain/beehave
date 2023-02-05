class_name EnterExitTest
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


func test_action_enter_exit() -> void:
	var enter_callback = func (actor, blackboard):
		blackboard.set_value("entered", true)
	
	var exit_callback = func (actor, blackboard):
		blackboard.set_value("exited", true)
	
	action.entered.connect(enter_callback)
	action.exited.connect(exit_callback)
	action.running_frame_count = 1
	
	assert_bool(tree.blackboard.get_value("entered", false), false)
	assert_bool(tree.blackboard.get_value("exited", false), false)
	
	assert_int(tree.tick()).is_equal(BeehaveNode.RUNNING)
	assert_bool(tree.blackboard.get_value("entered", false), true)
	assert_bool(tree.blackboard.get_value("exited", false), false)
	
	assert_int(tree.tick()).is_equal(BeehaveNode.SUCCESS)
	assert_bool(tree.blackboard.get_value("entered", false), true)
	assert_bool(tree.blackboard.get_value("exited", false), true)
	
