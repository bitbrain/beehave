# default value provider, simple returns the initial value
class_name DefaultValueProvider 
extends ValueProvider

var _value

func _init(value):
	_value = value
	
func get_value():
	return _value
