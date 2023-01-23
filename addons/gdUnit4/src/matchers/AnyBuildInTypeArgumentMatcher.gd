class_name AnyBuildInTypeArgumentMatcher
extends GdUnitArgumentMatcher

var _type :int

func _init(type :int):
	_type = type

func is_match(value) -> bool:
	return typeof(value) == _type
