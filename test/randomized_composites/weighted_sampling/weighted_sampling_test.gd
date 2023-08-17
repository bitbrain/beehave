# GdUnit generated TestSuite
class_name WeightedSamplingTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://test/randomized_composites/weighted_sampling/WeightedSamplingTestScene.tscn"

const SAMPLE_SIZE = 1_000
const ACCEPTABLE_RANGE = 3.0


func create_scene() -> Node2D:
	var scene = auto_free(load(__source).instantiate())
	scene.test_sample_count = SAMPLE_SIZE
	return scene


func test_weights_effecting_sample() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	
	runner.set_time_factor(500.0)
	
	await runner.await_signal("done", [], 5000)
	
	# Make sure the scene has reset enough times.
	assert_int(scene.reset_count).is_greater_equal(SAMPLE_SIZE)
	
	var result: Dictionary = scene.get_final_results()
	var weights: Dictionary = scene.sequence_random._weights
	
	# Both weights and the results should have the same keys.
	assert_array(result.keys()).contains_exactly_in_any_order(weights.keys())
	
	var weight_sum: float = weights.values()\
			.reduce(func(acc, n): return acc + n, 0.0)
	
	# The percentage of a node being the first should be more or less 
	# the value of the weight relative to the total of weights.
	for action in result.keys():
		var normalized_weight: float = (weights[action] / weight_sum) * 100.0
		assert_float(result[action]).is_equal_approx(normalized_weight, ACCEPTABLE_RANGE)
	
