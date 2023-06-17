class_name AnyBuildInTypeArgumentMatcher
extends GdUnitArgumentMatcher

var _type : PackedInt32Array = []

func _init(type :PackedInt32Array):
	_type = type

func is_match(value) -> bool:
	return _type.has(typeof(value))
