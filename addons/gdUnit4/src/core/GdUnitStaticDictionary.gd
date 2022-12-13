# implements a Dictionary with static accessors
class_name GdUnitStaticDictionary
extends RefCounted

const __store := [{}]

static func add_value(key : Variant, value : Variant, overwrite := false) -> Variant:
	if overwrite and __store[0].has(key):
		push_error("An value already exists with key: %s" % key)
		return null
	__store[0][key] = value
	return value

static func erase(key: Variant) -> bool:
	if __store[0].has(key):
		__store[0].erase(key)
		return true
	return false

static func clear() -> void:
	__store[0].clear()

func find_key(value: Variant) -> Variant:
	return __store[0].find_key(value)

static func get_value(key: Variant, default: Variant = null) -> Variant:
	return __store[0][key]

static func has_key(key: Variant) -> bool:
	return __store[0].has(key)

static func has_keys(keys: Array)  -> bool:
	return __store[0].has_all(keys)

static func hash() -> int:
	return __store[0].hash()

static func is_empty() -> bool:
	prints(__store)
	return __store[0].is_empty()
	
static func keys() -> Array:
	return __store[0].keys()
	
static func size() -> int:
	return __store[0].size()
	
static func values() -> Array:
	return __store[0].values()

func _to_string() -> String:
	return str(__store[0].keys())
