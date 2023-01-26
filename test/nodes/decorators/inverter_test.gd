# GdUnit generated TestSuite
class_name InverterTest
extends GdUnitTestSuite
@warning_ignore(unused_parameter)
@warning_ignore(return_value_discarded)

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/inverter.gd"

func test_invert_success_to_failure() -> void:
	var node = auto_free(load(__source).new())
	node.add_child(auto_free(load("res://addons/beehave/nodes/decorators/succeeder.gd").new()))
	assert_that(node.tick(null, null)).is_equal(BeehaveNode.FAILURE)
	
func test_invert_failure_to_success() -> void:
	var node = auto_free(load(__source).new())
	node.add_child(auto_free(load("res://addons/beehave/nodes/decorators/failer.gd").new()))
	assert_that(node.tick(null, null)).is_equal(BeehaveNode.SUCCESS)
