class_name GdUnitThreadManager
extends RefCounted

## { id:<int> = GdUnitThreadContext }
var _threads_by_id := {}



func _init():
	_threads_by_id[OS.get_main_thread_id()] = GdUnitThreadContext.new()


func _notification(what):
	prints("_notification", what)


static func instance() -> GdUnitThreadManager:
	return GdUnitSingleton.instance("GdUnitThreadManager", func(): return GdUnitThreadManager.new())


static func create_thread(name :String, cb :Callable) -> Thread:
	var t := Thread.new()
	t.set_meta("name", name)
	t.start(cb)
	instance().register_thread_context(t)
	return t


func register_thread_context(thread :Thread):
	_threads_by_id[thread.get_id() as int] = GdUnitThreadContext.new(thread)


func get_context(thread_id :int) -> GdUnitThreadContext:
	return _threads_by_id.get(thread_id)


static func get_current_context() -> GdUnitThreadContext:
	var current_thread_id := OS.get_thread_caller_id()
	return instance().get_context(current_thread_id)
