# GdUnit generated TestSuite
class_name DebuggerTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://addons/beehave/debug/debugger_tab.gd"
const TestScene = preload("res://test/debug/debugger_test_scene.tscn")

func create_scene() -> Node2D:
	return auto_free(TestScene.instantiate())
	
	
func test_debugger_renders_correctly():
	var scene = create_scene()
	var scene_runner = scene_runner(scene)
	await scene_runner.simulate_frames(20)
	await scene_runner.set_mouse_pos(Vector2(20, 20))
	await scene_runner.simulate_mouse_button_press(1)
	await scene_runner.simulate_frames(10)
