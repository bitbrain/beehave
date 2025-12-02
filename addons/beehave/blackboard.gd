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
	# Avoid sending raw Objects (Nodes, Resources, etc.) over the
	# EngineDebugger connection, which can cause Variant marshalling errors
	# and break the editor debugger stream.
	return _sanitize_for_debug(_data)


static func _sanitize_for_debug(value: Variant, depth: int = 0) -> Variant:
	# Limit recursion depth defensively to avoid issues with deeply nested
	# or self‑referential data structures. At this point we only need a
	# human‑readable representation for the debugger UI.
	if depth > 4:
		return str(value)

	var t := typeof(value)

	match t:
		TYPE_DICTIONARY:
			var result := {}
			for key in value.keys():
				var safe_key := _sanitize_for_debug(key, depth + 1)
				var safe_val := _sanitize_for_debug(value[key], depth + 1)
				result[safe_key] = safe_val
			return result

		TYPE_ARRAY:
			var arr: Array = []
			for v in value:
				arr.append(_sanitize_for_debug(v, depth + 1))
			return arr

		TYPE_OBJECT:
			if value == null:
				return null

			if value is Node:
				var path := ""
				if value.get_tree():
					path = str(value.get_path())
				return {
					"type": value.get_class(),
					"name": value.name,
					"path": path,
					"id": value.get_instance_id(),
				}

			if value is Resource:
				return {
					"type": value.get_class(),
					"resource_path": value.resource_path,
				}

			# Fallback: string representation is enough for the debugger.
			return str(value)

		_:
			return value
