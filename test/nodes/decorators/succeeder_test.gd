# GdUnit generated TestSuite
class_name SucceederTest
extends GdUnitTestSuite
@warning_ignore(unused_parameter)
@warning_ignore(return_value_discarded)

# TestSuite generated from
const __source = "res://addons/beehave/nodes/decorators/succeeder.gd"
const __failer = "res://addons/beehave/nodes/decorators/failer.gd"

func test_tick() -> void:
	var node = auto_free(load(__source).new())
	node.add_child(auto_free(load(__failer).new()))
	assert_that(node.tick(null, null)).is_equal(BeehaveNode.SUCCESS)
	
