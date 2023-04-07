class_name GdClassDescriptor
extends RefCounted


var _name :String
var _parent = null
var _is_inner_class :bool
var _functions


func _init(p_name :String, p_is_inner_class :bool, p_functions :Array):
	_name = p_name
	_is_inner_class = p_is_inner_class
	_functions = p_functions


func set_parent_clazz(p_parent :GdClassDescriptor):
	_parent = p_parent


func name() -> String:
	return _name


func parent() -> GdClassDescriptor:
	return _parent


func is_inner_class() -> bool:
	return _is_inner_class


func functions() -> Array:
	return _functions
