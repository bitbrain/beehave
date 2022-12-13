class_name CmdCommand
extends RefCounted

var _name: String
var _arguments: PackedStringArray

func _init(name: String, arguments: = []):
	_name = name
	_arguments = PackedStringArray(arguments)

func name() -> String:
	return _name

func arguments() -> PackedStringArray:
	return _arguments

func add_argument(arg: String) -> void:
	_arguments.append(arg)

func _to_string():
	return "%s:%s" % [_name, ", ".join(_arguments)]
