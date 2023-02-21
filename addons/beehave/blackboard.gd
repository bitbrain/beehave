## The blackboard is an object that can be used to store and access data between
## multiple nodes of the behavior tree.
@icon("icons/blackboard.svg")
class_name Blackboard extends Node

var blackboard: Dictionary = {}

func keys() -> Array[String]:
	var keys: Array[String]
	keys.assign(blackboard.keys().duplicate())
	return keys


func set_value(key: Variant, value: Variant, blackboard_name: String = 'default') -> void:
	if not blackboard.has(blackboard_name):
		blackboard[blackboard_name] = {}

	blackboard[blackboard_name][key] = value


func get_value(key: Variant, default_value: Variant = null, blackboard_name: String = 'default') -> Variant:
	if has_value(key, blackboard_name):
		return blackboard[blackboard_name].get(key, default_value)
	return default_value


func has_value(key: Variant, blackboard_name: String = 'default') -> bool:
	return blackboard.has(blackboard_name) and blackboard[blackboard_name].has(key) and blackboard[blackboard_name][key] != null


func erase_value(key: Variant, blackboard_name: String = 'default') -> void:
	if blackboard.has(blackboard_name):
		blackboard[blackboard_name][key] = null
