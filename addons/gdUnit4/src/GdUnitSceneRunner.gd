class_name GdUnitSceneRunner
extends RefCounted

const NO_ARG = GdUnitConstants.NO_ARG

func simulate(frames: int, delta_peer_frame :float) -> GdUnitSceneRunner:
	push_warning("DEPRECATED!: 'simulate(<frames>, <delta_peer_frame>)' is deprecated. Use  'simulate_frames(<frames>, <delta_milli>) instead.'")
	return simulate_frames(frames, delta_peer_frame * 1000)

func wait_emit_signal(instance :Object, signal_name :String, args := [], timeout := 2000, expeced := GdUnitAssert.EXPECT_SUCCESS):
	push_warning("DEPRECATED!: 'wait_emit_signal(<instance>, <signal_name>, <timeout>)' is deprecated. Use  'await_signal_on(<source>, <signal_name>, <timeout>) instead.'")
	return await await_signal_on(instance, signal_name, args, timeout).completed

func wait_func(source :Object, func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	push_warning("DEPRECATED!: 'wait_func(<source>, <func_name>, <args>)' is deprecated. Use  'await_func(<func_name>, <args>)' or 'await_func_on(<source>, <func_name>, <args>)' instead.")
	return await_func_on(source, func_name, args, expeced)

# Sets the mouse cursor to given position relative to the viewport.
func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	return self

# Simulates that a key has been pressed
# key_code : the key code e.g. 'KEY_ENTER'
# shift_pressed : false by default set to true if simmulate shift is press
# ctrl_pressed : false by default set to true if simmulate control is press
func simulate_key_pressed(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self

# Simulates that a key is pressed
# key_code : the key code e.g. 'KEY_ENTER'
# shift_pressed : false by default set to true if simmulate shift is press
# ctrl_pressed : false by default set to true if simmulate control is press
func simulate_key_press(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self

# Simulates that a key has been released
# key_code : the key code e.g. 'KEY_ENTER'
# shift_pressed : false by default set to true if simmulate shift is press
# ctrl_pressed : false by default set to true if simmulate control is press
func simulate_key_release(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self

# Simulates a mouse moved to relative position by given speed
# relative: The mouse position relative to the previous position (position at the last frame).
# speed : The mouse speed in pixels per second.‚
func simulate_mouse_move(relative :Vector2, speed :Vector2 = Vector2.ONE) -> GdUnitSceneRunner:
	return self

# Simulates a mouse button pressed
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_pressed(buttonIndex :int) -> GdUnitSceneRunner:
	return self

# Simulates a mouse button press (holding)
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_press(buttonIndex :int) -> GdUnitSceneRunner:
	return self

# Simulates a mouse button released
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_release(buttonIndex :int) -> GdUnitSceneRunner:
	return self

# Sets how fast or slow the scene simulation is processed (clock ticks versus the real).
# It defaults to 1.0. A value of 2.0 means the game moves twice as fast as real life,
# whilst a value of 0.5 means the game moves at half the regular speed.
func set_time_factor(time_factor := 1.0) -> GdUnitSceneRunner:
	return self

# Simulates scene processing for a certain number of frames
# frames: amount of frames to process
# delta_milli: the time delta between a frame in milliseconds
func simulate_frames(frames: int, delta_milli :int = -1) -> GdUnitSceneRunner:
	return self

# Simulates scene processing until the given signal is emitted by the scene
# signal_name: the signal to stop the simulation
# arg..: optional signal arguments to be matched for stop
func simulate_until_signal(signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	return self

# Simulates scene processing until the given signal is emitted by the given object
# source: the object that should emit the signal
# signal_name: the signal to stop the simulation
# arg..: optional signal arguments to be matched for stop	
func simulate_until_object_signal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	return self

# Waits for the function return value until specified timeout or fails
# args : optional function arguments
func await_func(func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	return null

# Waits for the function return value of specified source until specified timeout or fails
# source: the object where implements the function
# args : optional function arguments
func await_func_on(source :Object, func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	return null

# Waits for given signal is emited by the scene until a specified timeout to fail
# signal_name: signal name
# args: the expected signal arguments as an array
# timeout: the timeout in ms, default is set to 2000ms
func await_signal(signal_name :String, args := [], timeout := 2000 ):
	pass

# Waits for given signal is emited by the <source> until a specified timeout to fail
# source: the object from which the signal is emitted
# signal_name: signal name
# args: the expected signal arguments as an array
# timeout: the timeout in ms, default is set to 2000ms
func await_signal_on(source :Object, signal_name :String, args := [], timeout := 2000 ):
	pass

# maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	return self

# Return the current value of the property with the name <name>.
# name: name of property
# retuen: the value of the property
func get_property(name :String):
	pass

# executes the function specified by <name> in the scene and returns the result
# name: the name of the function to execute
# optional function args 0..9
# return: the function result
func invoke(name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	pass

# Searches for the specified node with the name in the current scene and returns it, otherwise null
# name: the name of the node to find
# recursive: enables/disables seraching recursive
# return: the node if find otherwise null
func find_child(name :String, recursive :bool = true, owned :bool = false) -> Node:
	return null

# Access to current running scene
func scene() -> Node:
	return null

