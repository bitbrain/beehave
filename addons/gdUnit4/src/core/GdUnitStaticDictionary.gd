# implements a Dictionary with static accessors
class_name GdUnitStaticDictionary
extends GdUnitSingleton


static func __data() -> Dictionary:
	return instance("GdUnitStaticVariables", func(): return {})


static func add_value(key : Variant, value : Variant, overwrite := false) -> Variant:
	var data :Dictionary = __data()
	if overwrite and data.has(key):
		push_error("An value already exists with key: %s" % key)
		return null
	data[key] = value
	#Engine.set_meta("GdUnitStaticVariables", data)
	return value


static func erase(key: Variant) -> bool:
	var data :Dictionary = __data()
	if data.has(key):
		data.erase(key)
		#Engine.set_meta("GdUnitStaticVariables", data)
		return true
	return false


static func clear() -> void:
	Engine.set_meta("GdUnitStaticVariables", {})


func find_key(value: Variant) -> Variant:
	return GdUnitStaticDictionary.__data().find_key(value)


static func get_value(key: Variant, default: Variant = null) -> Variant:
	return GdUnitStaticDictionary.__data().get(key, default)


static func has_key(key: Variant) -> bool:
	return __data().has(key)


static func has_keys(keys_: Array)  -> bool:
	return __data().has_all(keys_)


static func is_empty() -> bool:
	return __data().is_empty()


static func keys() -> Array:
	return __data().keys()


static func size() -> int:
	return __data().size()


static func values() -> Array:
	return __data().values()


func _to_string() -> String:
	return str(GdUnitStaticDictionary.__data().keys())
