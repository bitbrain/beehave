# GdUnit generated TestSuite
class_name E2ETest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

# TestSuite generated from
const __source = "res://examples/BeehaveTestScene.tscn"

func create_scene() -> Node2D:
	return auto_free(load(__source).instantiate())
	

func test_changing_to_all_colours() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	# speed up the test
	runner.set_time_factor(100.0)
	scene.sprite.position = Vector2(200, 200)
	await runner.simulate_until_object_signal(scene.sprite, "color_changed")
	assert_that(scene.sprite.modulate).is_equal(Color.RED)
	scene.sprite.position = Vector2(-200, 200)
	await runner.simulate_until_object_signal(scene.sprite, "color_changed")
	assert_that(scene.sprite.modulate).is_equal(Color.WHITE)
	scene.sprite.position = Vector2(-200, -200)
	await runner.simulate_until_object_signal(scene.sprite, "color_changed")
	assert_that(scene.sprite.modulate).is_equal(Color.BLUE)
	scene.sprite.position = Vector2(200, -200)
	await runner.simulate_until_object_signal(scene.sprite, "color_changed")
	assert_that(scene.sprite.modulate).is_equal(Color.WHITE)
