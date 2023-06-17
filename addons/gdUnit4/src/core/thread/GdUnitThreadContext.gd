class_name GdUnitThreadContext
extends RefCounted


var _thread :Thread
var _assert :GdUnitAssert
var _signal_collector :GdUnitSignalAssertImpl.SignalCollector


func _init(thread :Thread = null):
	_thread = thread
	_signal_collector = GdUnitSignalAssertImpl.SignalCollector.new()


func init() -> void:
	clear()


func clear() -> void:
	_assert = null
	if is_instance_valid(_signal_collector):
		_signal_collector.clear()


func set_assert(value :GdUnitAssert) -> GdUnitThreadContext:
	_assert = value
	return self


func get_assert() -> GdUnitAssert:
	return _assert


func get_signal_collector() -> GdUnitSignalAssertImpl.SignalCollector:
	return _signal_collector


func _to_string() -> String:
	var id := OS.get_main_thread_id() if _thread == null else int(_thread.get_id())
	var name := "main" if _thread == null else _thread.get_meta("name") as String
	#var assert_ = _assert if is_instance_valid(_assert) else null
	return "Thread <%s>: %s " % [name, id]
