class_name GdUnitSignalAwaiter
extends RefCounted

signal signal_emitted(action)

const NO_ARG :Variant = GdUnitConstants.NO_ARG

var _wait_on_idle_frame = false
var _interrupted := false
var _time_left := 0
var _timeout_millis :int


func _init(timeout_millis :int, wait_on_idle_frame := false):
	_timeout_millis = timeout_millis
	_wait_on_idle_frame = wait_on_idle_frame


func _on_signal_emmited(arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var signal_args :Variant = GdArrayTools.filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	signal_emitted.emit(signal_args)


func is_interrupted() -> bool:
	return _interrupted


func elapsed_time() -> int:
	return _time_left


func on_signal(source :Object, signal_name :String, expected_signal_args :Array) -> Variant:
	# register checked signal to wait for
	source.connect(signal_name, _on_signal_emmited)
	# install timeout timer
	var timer = Timer.new()
	Engine.get_main_loop().root.add_child(timer)
	timer.add_to_group("GdUnitTimers")
	timer.set_one_shot(true)
	timer.timeout.connect(func do_interrupt():
		_interrupted = true
		signal_emitted.emit(null)
	, CONNECT_DEFERRED)
	timer.start(_timeout_millis * 0.001 * Engine.get_time_scale())
	
	# holds the emited value
	var value :Variant
	# wait for signal is emitted or a timeout is happen
	while true:
		value = await signal_emitted
		if _interrupted:
			break
		if not (value is Array):
			value = [value]
		if expected_signal_args.size() == 0 or GdObjects.equals(value, expected_signal_args):
			break
		await Engine.get_main_loop().process_frame
	
	source.disconnect(signal_name, _on_signal_emmited)
	_time_left = timer.time_left
	await Engine.get_main_loop().process_frame
	if value is Array and value.size() == 1:
		return value[0]
	return value
