extends GdUnitTestSuite


const __source = "res://test/randomized_composites/weighted_sampling/selector_random/SelectorRandomWeights.tscn"

const ACCEPTABLE_RANGE = 5


func create_scene() -> Node2D:
	var scene = auto_free(load(__source).instantiate())
	return scene


func test_weights_effecting_sample() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	
	scene.set_weights(50, 30, 15, 5)
	
	runner.set_time_factor(100.0)
	await runner.simulate_frames(1000)
	
	var result: Dictionary = scene.get_final_results()
	var weights: Dictionary = scene.selector._weights
	
	# Both weights and the results should have the same keys.
	assert_array(result.keys()).contains_exactly_in_any_order(weights.keys())
	
	var weight_sum: float = weights.values()\
			.reduce(func(acc, n): return acc + n, 0.0)
	
	# The percentage of a node being the first should be more or less 
	# the value of the weight relative to the total of weights.
	for action in result.keys():
		var normalized_weight: float = (weights[action] / weight_sum) * 100.0
		assert_float(result[action]).is_equal_approx(normalized_weight, ACCEPTABLE_RANGE)
	
