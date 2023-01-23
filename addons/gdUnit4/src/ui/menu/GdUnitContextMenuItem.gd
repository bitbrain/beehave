class_name GdUnitContextMenuItem

enum MENU_ID {
	TEST_RUN = 1000,
	TEST_DEBUG = 1001,
	CREATE_TEST = 1010,
}

var _is_visible :Callable
var _is_enabled :Callable
var _runnable: Callable


func _init(id :MENU_ID, name :StringName, is_visible :Callable, is_enabled: Callable, runnable: Callable):
	self.id = id
	self.name = name
	_is_visible = is_visible
	_is_enabled = is_enabled
	_runnable = runnable


var id: MENU_ID:
	set(value):
		id = value
	get:
		return id


var name: StringName:
	set(value):
		name = value
	get:
		return name


func is_enabled(script :GDScript) -> bool:
	return _is_enabled.call(script)


func is_visible(script :GDScript) -> bool:
	return _is_visible.call(script)


func execute(args :Array) -> void:
	_runnable.callv(args)
