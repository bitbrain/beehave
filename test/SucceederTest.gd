# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnitSucceederTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/beehave/nodes/decorators/succeeder.gd'

const Succeeder = preload(__source)

func test_always_succeed() -> void:
	var succeeder = Succeeder.new()
	assert_int(succeeder.tick(null, null)).is_zero()
