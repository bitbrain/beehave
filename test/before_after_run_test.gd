class_name BeforeAfterRunTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const __mock_action = "res://test/actions/mock_action.gd"

var tree: BeehaveTree
var action: ActionLeaf


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action = auto_free(load(__mock_action).new())
	var succeeder = auto_free(BeehaveSucceeder.new())
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(succeeder)
	succeeder.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_action_after_run() -> void:
	var before_run_callback = func (_actor, blackboard):
		blackboard.set_value("entered", true)
	
	var after_run_callback = func (_actor, blackboard):
		blackboard.set_value("exited", true)
	
	action.started_running.connect(before_run_callback)
	action.stopped_running.connect(after_run_callback)
	action.running_frame_count = 1
	
	assert_bool(tree.blackboard.get_value("entered", false)).is_false()
	assert_bool(tree.blackboard.get_value("exited", false)).is_false()
	
	assert_int(tree.tick()).is_equal(BeehaveTreeNode.RUNNING)
	assert_bool(tree.blackboard.get_value("entered", false)).is_true()
	assert_bool(tree.blackboard.get_value("exited", false)).is_false()
	
	assert_int(tree.tick()).is_equal(BeehaveTreeNode.SUCCESS)
	assert_bool(tree.blackboard.get_value("entered", false)).is_true()
	assert_bool(tree.blackboard.get_value("exited", false)).is_true()
