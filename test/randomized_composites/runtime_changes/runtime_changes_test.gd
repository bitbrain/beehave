# GdUnit generated TestSuite
class_name RuntimeChangesTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const __source = "res://test/randomized_composites/runtime_changes/RuntimeChangesTestScene.tscn"
const __mock_action = "res://test/actions/mock_action.gd"

func create_scene() -> Node2D:
	var scene = auto_free(load(__source).instantiate())
	return scene


func create_new_action():
	var new_action = auto_free(load(__mock_action).new())
	new_action.name = "New Attack"
	return new_action


func test_add_child() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	
	runner.set_time_factor(100.0)
	
	var weights_before = scene.sequence_random._weights.duplicate()
	
	runner.simulate_frames(10)
	
	var new_action = create_new_action()
	scene.sequence_random.add_child(new_action)
	
	# Weights should have a new key with the added child.
	assert_dict(scene.sequence_random._weights)\
			.contains_key_value(new_action.name, 1)
	
	# All other children's weights should be the same.
	for node in weights_before.keys():
		assert_dict(scene.sequence_random._weights)\
				.contains_key_value(node, weights_before[node])
				
	runner.simulate_frames(10) # Everything should work fine afterwards.


func test_remove_child() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	
	runner.set_time_factor(100.0)
	
	var weights_before: Dictionary = scene.sequence_random._weights.duplicate()
	
	runner.simulate_frames(10)
	
	var removed_action = runner.find_child(weights_before.keys()[0])
	scene.sequence_random.remove_child(removed_action)
	
	# Weights should not have that action anymore.
	assert_dict(scene.sequence_random._weights)\
			.not_contains_keys([removed_action.name])
	
	# All other children's weights should be the same.
	var other_children = weights_before.keys()\
			.filter(func(k): return k != removed_action.name)
	for node in other_children:
		assert_dict(scene.sequence_random._weights)\
				.contains_key_value(node, weights_before[node])
	
	removed_action.queue_free()
	
	runner.simulate_frames(10) # Everything should work fine afterwards.


func test_rename_child() -> void:
	var scene = create_scene()
	var runner := scene_runner(scene)
	
	runner.set_time_factor(100.0)
	
	var weights_before: Dictionary = scene.sequence_random._weights.duplicate()
	
	runner.simulate_frames(10)
	
	var renamed_action = runner.find_child(weights_before.keys()[0])
	var previous_name = renamed_action.name
	renamed_action.name = "Renamed Action"
	
	# Weights should not have the old action name anymore.
	assert_dict(scene.sequence_random._weights)\
			.not_contains_keys([previous_name])
	
	# Weights should have the new name with the default weight.
	assert_dict(scene.sequence_random._weights)\
			.contains_key_value(renamed_action.name, 1)
	
	# All other children's weights should be the same.
	var other_children = weights_before.keys()\
			.filter(func(k): return k != previous_name)
	for node in other_children:
		assert_dict(scene.sequence_random._weights)\
				.contains_key_value(node, weights_before[node])
	
	runner.simulate_frames(10) # Everything should work fine afterwards.
