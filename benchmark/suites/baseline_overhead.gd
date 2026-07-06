## Measures the framework overhead of beehave by comparing the canonical
## community benchmark tree (selector with a failing condition falling
## through to a sequence of two actions) against the equivalent
## hand-written GDScript if/else logic.
extends "res://benchmark/bench.gd"

const Leaves := preload("res://benchmark/leaves.gd")

var _counter := 0


func title() -> String:
	return "Framework overhead vs raw GDScript"


func benchmark_gdscript_equivalent() -> Dictionary:
	return code_case(_tick_gdscript)


func benchmark_beehave_tree() -> Dictionary:
	var root := build(
		SelectorComposite,
		{},
		[
			build(Leaves.Condition, {status = FAILURE}),
			build(SequenceComposite, {}, [Leaves.Action.new(), Leaves.Action.new()]),
		]
	)
	return tree_case(root, {relative_to = "gdscript_equivalent"})


func _tick_gdscript() -> void:
	if _is_enemy_visible():
		return
	_move_forward()
	_play_animation()


func _is_enemy_visible() -> bool:
	return false


func _move_forward() -> void:
	_counter += 1


func _play_animation() -> void:
	_counter += 1
