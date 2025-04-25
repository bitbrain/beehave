@icon("icons/blackboard.svg")
class_name Blackboard extends Node

const DEFAULT = "default"

## The blackboard is an object that can be used to store and access data between
## multiple nodes of the behavior tree.
@export var blackboard: Dictionary = {}:
	set(b):
		blackboard = b.duplicate()
		_data[DEFAULT] = blackboard

var _data: Dictionary = {}


func _ready():
	blackboard = blackboard.duplicate()
	_data[DEFAULT] = blackboard


func keys() -> Array[String]:
	var keys: Array[String]
	keys.assign(_data.keys().duplicate())
	return keys


func set_value(key: Variant, value: Variant, blackboard_name: String = DEFAULT) -> void:
	if not _data.has(blackboard_name):
		_data[blackboard_name] = {}

	_data[blackboard_name][key] = value


func get_value(
	key: Variant, default_value: Variant = null, blackboard_name: String = DEFAULT
) -> Variant:
	if has_value(key, blackboard_name):
		return _data[blackboard_name].get(key, default_value)
	return default_value


func has_value(key: Variant, blackboard_name: String = DEFAULT) -> bool:
	return (
		_data.has(blackboard_name)
		and _data[blackboard_name].has(key)
		and _data[blackboard_name][key] != null
	)


func erase_value(key: Variant, blackboard_name: String = DEFAULT) -> void:
	if _data.has(blackboard_name):
		_data[blackboard_name][key] = null

func get_debug_data() -> Dictionary:
	return _data
