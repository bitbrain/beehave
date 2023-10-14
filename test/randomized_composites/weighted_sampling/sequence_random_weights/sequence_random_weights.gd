extends Node2D

signal done

# How many iterations should the test run.
@export var test_sample_count: int = 1_000

@onready var sequence_random: SequenceRandomComposite = %SequenceRandom

var reset_count: int = 0
var sample_count: Dictionary = {}


func set_weights(idle: int, run: int, attack_meele: int, attack_ranged: int):
	sequence_random.set("Weights/Idle", idle)
	sequence_random.set("Weights/Run", run)
	sequence_random.set("Weights/Attack Meele", attack_meele)
	sequence_random.set("Weights/Attack Ranged", attack_ranged)


func _on_sequence_reset(new_order: Array[Node]):
	reset_count += 1
	var first = new_order[0]
	if not sample_count.has(first.name):
		sample_count[first.name] = 0
	sample_count[first.name] += 1
	
	if reset_count >= test_sample_count:
		done.emit()


func get_final_results() -> Dictionary:
	var final_results = {}
	for node in sample_count.keys():
		var perc = float(sample_count[node]) / float(reset_count) * 100.0
		final_results[node] = perc
	return final_results
