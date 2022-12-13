class_name GdClassDescriptor
extends RefCounted


var _name :String
var _parent = null
var _is_inner_class :bool
var _functions

func _init(name :String,is_inner_class :bool,functions :Array):
	_name = name
	_is_inner_class = is_inner_class
	_functions = functions

func set_parent_clazz(parent :GdClassDescriptor):
	_parent = parent

func name() -> String:
	return _name

func parent() -> GdClassDescriptor:
	return _parent

func is_inner_class() -> bool:
	return _is_inner_class

func functions() -> Array:
	return _functions
