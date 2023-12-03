class_name GdUnitThreadContext
extends RefCounted

var _thread :Thread
var _thread_name :String
var _thread_id :int
var _assert :GdUnitAssert
var _signal_collector :GdUnitSignalCollector
var _execution_context :GdUnitExecutionContext


func _init(thread :Thread = null):
	if thread != null:
		_thread = thread
		_thread_name = thread.get_meta("name")
		_thread_id = thread.get_id() as int
	else:
		_thread_name = "main"
		_thread_id = OS.get_main_thread_id()
	_signal_collector = GdUnitSignalCollector.new()


func dispose() -> void:
	_assert = null
	if is_instance_valid(_signal_collector):
		_signal_collector.clear()
	_signal_collector = null
	_execution_context = null
	_thread = null


func set_assert(value :GdUnitAssert) -> GdUnitThreadContext:
	_assert = value
	return self


func get_assert() -> GdUnitAssert:
	return _assert


func set_execution_context(context :GdUnitExecutionContext) -> void:
	_execution_context = context


func get_execution_context() -> GdUnitExecutionContext:
	return _execution_context


func get_execution_context_id() -> int:
	return _execution_context.get_instance_id()


func get_signal_collector() -> GdUnitSignalCollector:
	return _signal_collector


func thread_id() -> int:
	return _thread_id


func _to_string() -> String:
	return "ThreadContext <%s>: %s " % [_thread_name, _thread_id]
