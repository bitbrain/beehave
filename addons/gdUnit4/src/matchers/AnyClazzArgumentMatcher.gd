class_name AnyClazzArgumentMatcher 
extends GdUnitArgumentMatcher
	
var _clazz :Object

func _init(clazz :Object):
	_clazz = clazz

func is_match(value :Variant) -> bool:
	if typeof(value) != TYPE_OBJECT:
		return false
	if is_instance_valid(value) and GdObjects.is_script(_clazz):
		return value.get_script() == _clazz
	return is_instance_of(value, _clazz)
