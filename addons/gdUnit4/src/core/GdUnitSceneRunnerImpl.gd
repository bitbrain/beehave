# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunnerImpl
extends GdUnitSceneRunner


var GdUnitFuncAssertImpl := ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitFuncAssertImpl.gd", "GDScript", ResourceLoader.CACHE_MODE_REUSE)


# mapping of mouse buttons and his masks
const MAP_MOUSE_BUTTON_MASKS := {
	MOUSE_BUTTON_LEFT : MOUSE_BUTTON_MASK_LEFT,
	MOUSE_BUTTON_RIGHT : MOUSE_BUTTON_MASK_RIGHT,
	MOUSE_BUTTON_MIDDLE : MOUSE_BUTTON_MASK_MIDDLE,
	# https://github.com/godotengine/godot/issues/73632
	MOUSE_BUTTON_WHEEL_UP : 1 << (MOUSE_BUTTON_WHEEL_UP - 1),
	MOUSE_BUTTON_WHEEL_DOWN : 1 << (MOUSE_BUTTON_WHEEL_DOWN - 1),
	MOUSE_BUTTON_XBUTTON1 : MOUSE_BUTTON_MASK_MB_XBUTTON1,
	MOUSE_BUTTON_XBUTTON2 : MOUSE_BUTTON_MASK_MB_XBUTTON2,
}

var _scene_tree :SceneTree = null
var _current_scene :Node = null
var _awaiter :GdUnitAwaiter = GdUnitAwaiter.new()
var _verbose :bool
var _simulate_start_time :LocalTime
var _last_input_event :InputEvent = null
var _mouse_button_on_press := []
var _key_on_press := []
var _curent_mouse_position :Vector2

# time factor settings
var _time_factor := 1.0
var _saved_iterations_per_second :float
var _scene_auto_free := false


func _init(p_scene, p_verbose :bool, p_hide_push_errors = false):
	_verbose = p_verbose
	_saved_iterations_per_second = Engine.get_physics_ticks_per_second()
	set_time_factor(1)
	# handle scene loading by resource path
	if typeof(p_scene) == TYPE_STRING:
		if !FileAccess.file_exists(p_scene):
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: Can't load scene by given resource path: '%s'. The resource not exists." % p_scene)
			return
		if !str(p_scene).ends_with("tscn"):
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: The given resource: '%s'. is not a scene." % p_scene)
			return
		_current_scene = load(p_scene).instantiate()
		_scene_auto_free = true
	else:
		# verify we have a node instance
		if not p_scene is Node:
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: The given instance '%s' is not a Node." % p_scene)
			return
		_current_scene = p_scene
	if _current_scene == null:
		if not p_hide_push_errors:
			push_error("GdUnitSceneRunner: Scene must be not null!")
		return
	_scene_tree = Engine.get_main_loop()
	_scene_tree.root.add_child(_current_scene)
	_simulate_start_time = LocalTime.now()
	# we need to set inital a valid window otherwise the warp_mouse() is not handled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# set inital mouse pos to 0,0
	var max_iteration_to_wait = 0
	while get_global_mouse_position() != Vector2.ZERO and max_iteration_to_wait < 100:
		Input.warp_mouse(Vector2.ZERO)
		max_iteration_to_wait += 1


func _notification(what):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(self):
		# reset time factor to normal
		__deactivate_time_factor()
		_reset_input_to_default()
		if is_instance_valid(_current_scene):
			_scene_tree.root.remove_child(_current_scene)
			# do only free scenes instanciated by this runner
			if _scene_auto_free:
				_current_scene.free()
		_scene_tree = null
		_current_scene = null
		# we hide the scene/main window after runner is finished 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func simulate_key_pressed(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	simulate_key_press(key_code, shift_pressed, ctrl_pressed)
	simulate_key_release(key_code, shift_pressed, ctrl_pressed)
	return self


func simulate_key_press(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var event = InputEventKey.new()
	event.pressed = true
	event.keycode = key_code
	event.physical_keycode = key_code
	event.alt_pressed = key_code == KEY_ALT
	event.shift_pressed = shift_pressed or key_code == KEY_SHIFT
	event.ctrl_pressed = ctrl_pressed or key_code == KEY_CTRL
	_apply_input_modifiers(event)
	_key_on_press.append(key_code)
	return _handle_input_event(event)


func simulate_key_release(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var event = InputEventKey.new()
	event.pressed = false
	event.keycode = key_code
	event.physical_keycode = key_code
	event.alt_pressed = key_code == KEY_ALT
	event.shift_pressed = shift_pressed or key_code == KEY_SHIFT
	event.ctrl_pressed = ctrl_pressed or key_code == KEY_CTRL
	_apply_input_modifiers(event)
	_key_on_press.erase(key_code)
	return _handle_input_event(event)


func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	var event := InputEventMouseMotion.new()
	event.position = pos
	event.global_position = get_global_mouse_position()
	_apply_input_modifiers(event)
	return _handle_input_event(event)


func get_mouse_position() -> Vector2:
	if _last_input_event is InputEventMouse:
		return _last_input_event.position
	return _current_scene.get_viewport().get_mouse_position()


func get_global_mouse_position() -> Vector2:
	return _scene_tree.root.get_mouse_position()


func simulate_mouse_move(pos :Vector2) -> GdUnitSceneRunner:
	var event := InputEventMouseMotion.new()
	event.position = pos
	event.relative = pos - get_mouse_position()
	event.global_position = get_global_mouse_position()
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	return _handle_input_event(event)


func simulate_mouse_move_relative(relative: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	var tween := _scene_tree.create_tween()
	_curent_mouse_position = get_mouse_position()
	var final_position := _curent_mouse_position + relative
	tween.tween_property(self, "_curent_mouse_position", final_position, time).set_trans(trans_type)
	tween.play()
	
	while not get_mouse_position().is_equal_approx(final_position):
		simulate_mouse_move(_curent_mouse_position)
		await _scene_tree.process_frame
	return self


func simulate_mouse_move_absolute(position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	var tween := _scene_tree.create_tween()
	_curent_mouse_position = get_mouse_position()
	tween.tween_property(self, "_curent_mouse_position", position, time).set_trans(trans_type)
	tween.play()
	
	while not get_mouse_position().is_equal_approx(position):
		simulate_mouse_move(_curent_mouse_position)
		await _scene_tree.process_frame
	return self


func simulate_mouse_button_pressed(buttonIndex :MouseButton, double_click := false) -> GdUnitSceneRunner:
	simulate_mouse_button_press(buttonIndex, double_click)
	simulate_mouse_button_release(buttonIndex)
	return self


func simulate_mouse_button_press(buttonIndex :MouseButton, double_click := false) -> GdUnitSceneRunner:
	var event := InputEventMouseButton.new()
	event.button_index = buttonIndex
	event.pressed = true
	event.double_click = double_click
	_apply_input_mouse_position(event)
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	_mouse_button_on_press.append(buttonIndex)
	return _handle_input_event(event)


func simulate_mouse_button_release(buttonIndex :MouseButton) -> GdUnitSceneRunner:
	var event := InputEventMouseButton.new()
	event.button_index = buttonIndex
	event.pressed = false
	_apply_input_mouse_position(event)
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	_mouse_button_on_press.erase(buttonIndex)
	return _handle_input_event(event)


func set_time_factor(time_factor := 1.0) -> GdUnitSceneRunner:
	_time_factor = min(9.0, time_factor)
	__activate_time_factor()
	__print("set time factor: %f" % _time_factor)
	__print("set physics physics_ticks_per_second: %d" % (_saved_iterations_per_second*_time_factor))
	return self


func simulate_frames(frames: int, delta_milli :int = -1) -> GdUnitSceneRunner:
	var time_shift_frames :int = max(1, frames / _time_factor)
	for frame in time_shift_frames:
		if delta_milli == -1:
			await _scene_tree.process_frame
		else:
			await _scene_tree.create_timer(delta_milli * 0.001).timeout
	return self


func simulate_until_signal(signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	var args = GdArrayTools.filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	await _awaiter.await_signal_idle_frames(_current_scene, signal_name, args, 10000)
	return self


func simulate_until_object_signal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	var args = GdArrayTools.filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	await _awaiter.await_signal_idle_frames(source, signal_name, args, 10000)
	return self


func await_func(func_name :String, args := []) -> GdUnitFuncAssert:
	return GdUnitFuncAssertImpl.new(_current_scene, func_name, args)


func await_func_on(instance :Object, func_name :String, args := []) -> GdUnitFuncAssert:
	return GdUnitFuncAssertImpl.new(instance, func_name, args)


func await_signal(signal_name :String, args := [], timeout := 2000 ):
	await _awaiter.await_signal_on(_current_scene, signal_name, args, timeout)


func await_signal_on(source :Object, signal_name :String, args := [], timeout := 2000 ):
	await _awaiter.await_signal_on(source, signal_name, args, timeout)


# maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_move_to_foreground()
	return self


func _property_exists(name :String) -> bool:
	return _current_scene.get_property_list().any(func(properties :Dictionary) : return properties["name"] == name)


func get_property(name :String) -> Variant:
	if not _property_exists(name):
		return "The property '%s' not exist checked loaded scene." % name
	return _current_scene.get(name)


func set_property(name :String, value :Variant) -> bool:
	if not _property_exists(name):
		push_error("The property named '%s' cannot be set, it does not exist!" % name)
		return false;
	_current_scene.set(name, value)
	return true


func invoke(name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var args = GdArrayTools.filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	if _current_scene.has_method(name):
		return _current_scene.callv(name, args)
	return "The method '%s' not exist checked loaded scene." % name


func find_child(name :String, recursive :bool = true, owned :bool = false) -> Node:
	return _current_scene.find_child(name, recursive, owned)


func _scene_name() -> String:
	var scene_script :GDScript = _current_scene.get_script()
	var scene_name :String = _current_scene.get_name()
	if not scene_script:
		return scene_name
	if not scene_name.begins_with("@"):
		return scene_name
	return scene_script.resource_name.get_basename()


func __activate_time_factor() -> void:
	Engine.set_time_scale(_time_factor)
	Engine.set_physics_ticks_per_second((_saved_iterations_per_second * _time_factor) as int)


func __deactivate_time_factor() -> void:
	Engine.set_time_scale(1)
	Engine.set_physics_ticks_per_second(_saved_iterations_per_second as int)


# copy over current active modifiers
func _apply_input_modifiers(event :InputEvent) -> void:
	if _last_input_event is InputEventWithModifiers and event is InputEventWithModifiers:
		event.meta_pressed = event.meta_pressed or _last_input_event.meta_pressed
		event.alt_pressed = event.alt_pressed or _last_input_event.alt_pressed
		event.shift_pressed = event.shift_pressed or _last_input_event.shift_pressed
		event.ctrl_pressed = event.ctrl_pressed or _last_input_event.ctrl_pressed
		# this line results into reset the control_pressed state!!!
		#event.command_or_control_autoremap = event.command_or_control_autoremap or _last_input_event.command_or_control_autoremap


# copy over current active mouse mask and combine with curren mask
func _apply_input_mouse_mask(event :InputEvent) -> void:
	# first apply last mask
	if _last_input_event is InputEventMouse and event is InputEventMouse:
		event.button_mask |= _last_input_event.button_mask
	if event is InputEventMouseButton:
		var button_mask = MAP_MOUSE_BUTTON_MASKS.get(event.get_button_index(), 0)
		if event.is_pressed():
			event.button_mask |= button_mask
		else:
			event.button_mask ^= button_mask


# copy over last mouse position if need
func _apply_input_mouse_position(event :InputEvent) -> void:
	if _last_input_event is InputEventMouse and event is InputEventMouseButton:
		event.position = _last_input_event.position


## just for testing maunally event to action handling
func _handle_actions(event :InputEvent) -> bool:
	var is_action_match := false
	for action in InputMap.get_actions():
		if InputMap.event_is_action(event, action, true):
			is_action_match = true
			prints(action, event, event.is_ctrl_pressed())
			if event.is_pressed():
				Input.action_press(action, InputMap.action_get_deadzone(action))
			else:
				Input.action_release(action)
	return is_action_match


# for handling read https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html?highlight=inputevent#how-does-it-work
func _handle_input_event(event :InputEvent):
	if event is InputEventMouse:
		Input.warp_mouse(event.position)
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	
	if is_instance_valid(_current_scene):
		__print("	process event %s (%s) <- %s" % [_current_scene, _scene_name(), event.as_text()])
		if(_current_scene.has_method("_gui_input")):
			_current_scene._gui_input(event)
		if(_current_scene.has_method("_unhandled_input")):
			_current_scene._unhandled_input(event)
		_current_scene.get_viewport().set_input_as_handled()
	# save last input event needs to be merged with next InputEventMouseButton
	_last_input_event = event
	return self


func _reset_input_to_default() -> void:
	# reset all mouse button to inital state if need
	for m_button in _mouse_button_on_press.duplicate():
		if Input.is_mouse_button_pressed(m_button):
			simulate_mouse_button_release(m_button)
	_mouse_button_on_press.clear()
	
	for key_scancode in _key_on_press.duplicate():
		if Input.is_key_pressed(key_scancode):
			simulate_key_release(key_scancode)
	_key_on_press.clear()
	Input.flush_buffered_events()
	_last_input_event = null


func __print(message :String) -> void:
	if _verbose:
		prints(message)


func __print_current_focus() -> void:
	if not _verbose:
		return
	var focused_node = _current_scene.get_viewport().gui_get_focus_owner()
	if focused_node:
		prints("	focus checked %s" % focused_node)
	else:
		prints("	no focus set")


func scene() -> Node:
	return _current_scene
