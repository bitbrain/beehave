class_name CmdOptions
extends RefCounted


var _default_options :Array
var _advanced_options :Array


func _init(options :Array = Array(),advanced_options :Array = Array()):
	# default help options
	_default_options = options 
	_advanced_options = advanced_options

func default_options() -> Array:
	return _default_options

func advanced_options() -> Array:
	return _advanced_options

func options() -> Array:
	return default_options() + advanced_options()

func get_option(cmd :String) -> CmdOption:
	for option in options():
		if Array(option.commands()).has(cmd):
			return option
	return null
