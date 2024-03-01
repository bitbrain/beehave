# GdUnit generated TestSuite
class_name FailerTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __action = "res://test/actions/count_up_action.gd"

var tree: BeehaveTree
var action: BeehaveAction
var failer: BeehaveFailer


func before_test() -> void:
	tree = auto_free(BeehaveTree.new())
	action = auto_free(load(__action).new())
	failer = auto_free(BeehaveFailer.new())
	
	var actor = auto_free(Node2D.new())
	var blackboard = auto_free(BeehaveBlackboard.new())
	
	tree.add_child(failer)
	failer.add_child(action)
	
	tree.actor = actor
	tree.blackboard = blackboard


func test_tick() -> void:
	action.status = BeehaveTreeNode.SUCCESS
	assert_that(tree.tick()).is_equal(BeehaveTreeNode.FAILURE)


#func test_clear_running_child_after_run() -> void:
#	action.status = BeehaveTreeNode.RUNNING
#	tree.tick()
#	assert_that(failer.running_child).is_equal(action)
#	action.status = BeehaveTreeNode.SUCCESS
#	tree.tick()
#	assert_that(failer.running_child).is_equal(null)
