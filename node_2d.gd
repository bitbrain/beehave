extends Node2D

var results: Dictionary

var times_reseted: int = 0

@onready var label: Label = $Label

func _on_sequence_random_composite_reseted(new_order):
	times_reseted += 1
	var first = new_order[0]
	if not results.has(first.name):
		results[first.name] = 0
	results[first.name] += 1
	_update_label()

func _update_label():
	var text = "resets: %d\n" % times_reseted
	for node in results.keys():
		var perc = float(results[node]) / float(times_reseted) * 100.0
		text += "%s: %.2f%%\n" % [node, perc]
	label.text = text
