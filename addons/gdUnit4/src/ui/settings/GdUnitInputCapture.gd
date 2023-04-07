@tool
class_name GdUnitInputCapture
extends Control


signal input_completed(input_event :InputEventKey)

@onready var _label = %Label


var _tween :Tween
var _input_event :InputEventKey


func _ready():
	reset()
	_tween = create_tween()
	_tween.set_loops(-1)
	_tween.tween_property(self, "modulate", Color(0, 0, 0, .1), 1.0).from_current().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func reset() -> void:
	_input_event = InputEventKey.new()


func _input(event :InputEvent):
	if not is_visible_in_tree():
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.keycode:
			KEY_CTRL: 
				_input_event.ctrl_pressed = true
			KEY_SHIFT: 
				_input_event.shift_pressed = true
			KEY_ALT: 
				_input_event.alt_pressed = true
			KEY_META: 
				_input_event.meta_pressed = true
			_: 
				_input_event.keycode = event.keycode
		_apply_input_modifiers(event)
		accept_event()
	
	if event is InputEventKey and not event.is_pressed():
		input_completed.emit(_input_event)
		hide()


func _apply_input_modifiers(event :InputEvent) -> void:
	if event is InputEventWithModifiers:
		_input_event.meta_pressed = event.meta_pressed or _input_event.meta_pressed
		_input_event.alt_pressed = event.alt_pressed or _input_event.alt_pressed
		_input_event.shift_pressed = event.shift_pressed or _input_event.shift_pressed
		_input_event.ctrl_pressed = event.ctrl_pressed or _input_event.ctrl_pressed
