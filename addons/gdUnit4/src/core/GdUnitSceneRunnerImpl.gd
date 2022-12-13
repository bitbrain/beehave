# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunnerImpl
extends GdUnitSceneRunner

var _test_suite :WeakRef
var _scene_tree :SceneTree = null
var _current_scene :Node = null
var _verbose :bool
var _simulate_start_time :LocalTime
var _current_mouse_pos :Vector2

# time factor settings
var _time_factor := 1.0
var _saved_time_scale :float
var _saved_iterations_per_second :float

func _init(test_suite :WeakRef, scene, verbose :bool, hide_push_errors = false):
	_verbose = verbose
	_test_suite = test_suite
	_saved_iterations_per_second = Engine.get_physics_ticks_per_second()
	set_time_factor(1)
	# handle scene loading by resource path
	if typeof(scene) == TYPE_STRING:
		if !FileAccess.file_exists(scene):
			if not hide_push_errors:
				push_error("GdUnitSceneRunner: Can't load scene by given resource path: '%s'. The resource not exists." % scene)
			return
		if !str(scene).ends_with("tscn"):
			if not hide_push_errors:
				push_error("GdUnitSceneRunner: The given resource: '%s'. is not a scene." % scene)
			return
		_current_scene =  load(scene).instantiate()
	else:
		# verify we have a node instance
		if not scene is Node:
			if not hide_push_errors:
				push_error("GdUnitSceneRunner: The given instance '%s' is not a Node." % scene)
			return
		_current_scene = scene
	if _current_scene == null:
		if not hide_push_errors:
			push_error("GdUnitSceneRunner: Scene must be not null!")
		return
	_scene_tree = Engine.get_main_loop()
	_scene_tree.root.add_child(_current_scene)
	_simulate_start_time = LocalTime.now()

func _notification(what):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(self):
		# reset time factor to normal
		__deactivate_time_factor()
		if is_instance_valid(_current_scene):
			_scene_tree.root.remove_child(_current_scene)
			# don't free already memory managed instances
			if not GdUnitMemoryPool.is_auto_free_registered(_current_scene):
				_current_scene.free()
		_scene_tree = null
		_current_scene = null
		_test_suite = null
		# we hide the scene/main window after runner is finished 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func simulate_key_pressed(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	simulate_key_press(key_code, shift_pressed, ctrl_pressed)
	simulate_key_release(key_code, shift_pressed, ctrl_pressed)
	return self

func simulate_key_press(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = true
	action.keycode = key_code
	action.shift_pressed = shift_pressed
	action.ctrl_pressed = ctrl_pressed
	__print("	process key event %s (%s) <- %s:%s" % [_current_scene, _scene_name(), action.as_text(), "pressing" if action.is_pressed() else "released"])
	_current_scene.get_viewport().push_input(action)
	return self

func simulate_key_release(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = false
	action.keycode = key_code
	action.shift_pressed = shift_pressed
	action.ctrl_pressed = ctrl_pressed
	__print("	process key event %s (%s) <- %s:%s" % [_current_scene, _scene_name(), action.as_text(), "pressing" if action.is_pressed() else "released"])
	_current_scene.get_viewport().push_input(action)
	return self

func simulate_mouse_move(relative :Vector2, speed :Vector2 = Vector2.ONE) -> GdUnitSceneRunner:
	var action := InputEventMouseMotion.new()
	action.relative = relative
	action.speed = speed
	__print("	process mouse motion event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
	_current_scene.get_viewport().push_input(action)
	return self

func simulate_mouse_button_pressed(buttonIndex :int) -> GdUnitSceneRunner:
	simulate_mouse_button_press(buttonIndex)
	simulate_mouse_button_release(buttonIndex)
	return self

func simulate_mouse_button_press(buttonIndex :int) -> GdUnitSceneRunner:
	var action := InputEventMouseButton.new()
	action.button_index = buttonIndex
	action.button_mask = buttonIndex
	action.pressed = true
	action.position = _current_mouse_pos
	__print("	process mouse button event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
	_current_scene.get_viewport().push_input(action)
	return self

func simulate_mouse_button_release(buttonIndex :int) -> GdUnitSceneRunner:
	var action := InputEventMouseButton.new()
	action.button_index = buttonIndex
	action.button_mask = 0
	action.pressed = false
	action.position = _current_mouse_pos
	__print("	process mouse button event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
	_current_scene.get_viewport().push_input(action)
	return self

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
	var args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	await GdUnitAwaiter.await_signal_idle_frames(_test_suite, _current_scene, signal_name, args, 10000)
	return self

func simulate_until_object_signal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	var args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	await GdUnitAwaiter.await_signal_idle_frames(_test_suite, source, signal_name, args, 10000)
	return self

func await_func(func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	return GdUnitFuncAssertImpl.new(_test_suite, _current_scene, func_name, args, expeced)

func await_func_on(instance :Object, func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	return GdUnitFuncAssertImpl.new(_test_suite, instance, func_name, args, expeced)

func await_signal(signal_name :String, args := [], timeout := 2000 ):
	await GdUnitAwaiter.await_signal_on(_test_suite, _current_scene, signal_name, args, timeout)

func await_signal_on(source :Object, signal_name :String, args := [], timeout := 2000 ):
	await GdUnitAwaiter.await_signal_on(_test_suite, source, signal_name, args, timeout)

func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	_current_scene.get_viewport().warp_mouse(pos)
	_current_mouse_pos = pos
	return self

# maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	#DisplayServer.center_window()
	DisplayServer.window_move_to_foreground()
	return self

func get_property(name :String):
	var property = _current_scene.get(name)
	if property != null:
		return property
	return  "The property '%s' not exist checked loaded scene." % name

func invoke(name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
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
	Engine.set_physics_ticks_per_second(_saved_iterations_per_second * _time_factor)

func __deactivate_time_factor() -> void:
	Engine.set_time_scale(1)
	Engine.set_physics_ticks_per_second(_saved_iterations_per_second)

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
