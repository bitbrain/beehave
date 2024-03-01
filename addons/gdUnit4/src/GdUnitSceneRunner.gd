## The scene runner for GdUnit to simmulate scene interactions
class_name GdUnitSceneRunner
extends RefCounted

const NO_ARG = GdUnitConstants.NO_ARG


## Sets the mouse cursor to given position relative to the viewport.
@warning_ignore("unused_parameter")
func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	return self


## Gets the current mouse position of the current viewport
func get_mouse_position() -> Vector2:
	return Vector2.ZERO


## Gets the current global mouse position of the current window
func get_global_mouse_position() -> Vector2:
	return Vector2.ZERO


## Simulates that a key has been pressed.[br]
## [member key_code] : the key code e.g. [constant KEY_ENTER][br]
## [member shift_pressed] : false by default set to true if simmulate shift is press[br]
## [member ctrl_pressed] : false by default set to true if simmulate control is press[br]
@warning_ignore("unused_parameter")
func simulate_key_pressed(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self


## Simulates that a key is pressed.[br]
## [member key_code] : the key code e.g. [constant KEY_ENTER][br]
## [member shift_pressed] : false by default set to true if simmulate shift is press[br]
## [member ctrl_pressed] : false by default set to true if simmulate control is press[br]
@warning_ignore("unused_parameter")
func simulate_key_press(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self


## Simulates that a key has been released.[br]
## [member key_code] : the key code e.g. [constant KEY_ENTER][br]
## [member shift_pressed] : false by default set to true if simmulate shift is press[br]
## [member ctrl_pressed] : false by default set to true if simmulate control is press[br]
@warning_ignore("unused_parameter")
func simulate_key_release(key_code :int, shift_pressed := false, ctrl_pressed := false) -> GdUnitSceneRunner:
	return self


## Simulates a mouse moved to final position.[br]
## [member pos] : The final mouse position
@warning_ignore("unused_parameter")
func simulate_mouse_move(pos :Vector2) -> GdUnitSceneRunner:
	return self


## Simulates a mouse move to the relative coordinates (offset).[br]
## [member relative] : The relative position, indicating the mouse position offset.[br]
## [member time] : The time to move the mouse by the relative position in seconds (default is 1 second).[br]
## [member trans_type] : Sets the type of transition used (default is TRANS_LINEAR).[br]
@warning_ignore("unused_parameter")
func simulate_mouse_move_relative(relative: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	await Engine.get_main_loop().process_frame
	return self


## Simulates a mouse move to the absolute coordinates.[br]
## [member position] : The final position of the mouse.[br]
## [member time] : The time to move the mouse to the final position in seconds (default is 1 second).[br]
## [member trans_type] : Sets the type of transition used (default is TRANS_LINEAR).[br]
@warning_ignore("unused_parameter")
func simulate_mouse_move_absolute(position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	await Engine.get_main_loop().process_frame
	return self


## Simulates a mouse button pressed.[br]
## [member buttonIndex] : The mouse button identifier, one of the [enum MouseButton] or button wheel constants.
@warning_ignore("unused_parameter")
func simulate_mouse_button_pressed(buttonIndex :MouseButton, double_click := false) -> GdUnitSceneRunner:
	return self


## Simulates a mouse button press (holding)[br]
## [member buttonIndex] : The mouse button identifier, one of the [enum MouseButton] or button wheel constants.
@warning_ignore("unused_parameter")
func simulate_mouse_button_press(buttonIndex :MouseButton, double_click := false) -> GdUnitSceneRunner:
	return self


## Simulates a mouse button released.[br]
## [member buttonIndex] : The mouse button identifier, one of the [enum MouseButton] or button wheel constants.
@warning_ignore("unused_parameter")
func simulate_mouse_button_release(buttonIndex :MouseButton) -> GdUnitSceneRunner:
	return self


## Sets how fast or slow the scene simulation is processed (clock ticks versus the real).[br]
## It defaults to 1.0. A value of 2.0 means the game moves twice as fast as real life,
## whilst a value of 0.5 means the game moves at half the regular speed.
@warning_ignore("unused_parameter")
func set_time_factor(time_factor := 1.0) -> GdUnitSceneRunner:
	return self


## Simulates scene processing for a certain number of frames.[br]
## [member frames] : amount of frames to process[br]
## [member delta_milli] : the time delta between a frame in milliseconds
@warning_ignore("unused_parameter")
func simulate_frames(frames: int, delta_milli :int = -1) -> GdUnitSceneRunner:
	await Engine.get_main_loop().process_frame
	return self


## Simulates scene processing until the given signal is emitted by the scene.[br]
## [member signal_name] : the signal to stop the simulation[br]
## [member args] : optional signal arguments to be matched for stop[br]
@warning_ignore("unused_parameter")
func simulate_until_signal(signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	await Engine.get_main_loop().process_frame
	return self


## Simulates scene processing until the given signal is emitted by the given object.[br]
## [member source] : the object that should emit the signal[br]
## [member signal_name] : the signal to stop the simulation[br]
## [member args] : optional signal arguments to be matched for stop
@warning_ignore("unused_parameter")
func simulate_until_object_signal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG) -> GdUnitSceneRunner:
	await Engine.get_main_loop().process_frame
	return self


## Waits for the function return value until specified timeout or fails.[br]
## [member args] : optional function arguments
@warning_ignore("unused_parameter")
func await_func(func_name :String, args := []) -> GdUnitFuncAssert:
	return null


## Waits for the function return value of specified source until specified timeout or fails.[br]
## [member source : the object where implements the function[br]
## [member args] : optional function arguments
@warning_ignore("unused_parameter")
func await_func_on(source :Object, func_name :String, args := []) -> GdUnitFuncAssert:
	return null


## Waits for given signal is emited by the scene until a specified timeout to fail.[br]
## [member signal_name] : signal name[br]
## [member args] : the expected signal arguments as an array[br]
## [member timeout] : the timeout in ms, default is set to 2000ms
@warning_ignore("unused_parameter")
func await_signal(signal_name :String, args := [], timeout := 2000 ):
	await Engine.get_main_loop().process_frame
	pass


## Waits for given signal is emited by the <source> until a specified timeout to fail.[br]
## [member source] : the object from which the signal is emitted[br]
## [member signal_name] : signal name[br]
## [member args] : the expected signal arguments as an array[br]
## [member timeout] : the timeout in ms, default is set to 2000ms
@warning_ignore("unused_parameter")
func await_signal_on(source :Object, signal_name :String, args := [], timeout := 2000 ):
	pass


## maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	return self


## Return the current value of the property with the name <name>.[br]
## [member name] : name of property[br]
## [member return] : the value of the property
@warning_ignore("unused_parameter")
func get_property(name :String) -> Variant:
	return null

## Set the  value <value> of the property with the name <name>.[br]
## [member name] : name of property[br]
## [member value] : value of property[br]
## [member return] : true|false depending on valid property name.
@warning_ignore("unused_parameter")
func set_property(name :String, value :Variant) -> bool:
	return false


## executes the function specified by <name> in the scene and returns the result.[br]
## [member name] : the name of the function to execute[br]
## [member args] : optional function arguments[br]
## [member return] : the function result
@warning_ignore("unused_parameter")
func invoke(name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	pass


## Searches for the specified node with the name in the current scene and returns it, otherwise null.[br]
## [member name] : the name of the node to find[br]
## [member recursive] : enables/disables seraching recursive[br]
## [member return] : the node if find otherwise null
@warning_ignore("unused_parameter")
func find_child(name :String, recursive :bool = true, owned :bool = false) -> Node:
	return null


## Access to current running scene
func scene() -> Node:
	return null
