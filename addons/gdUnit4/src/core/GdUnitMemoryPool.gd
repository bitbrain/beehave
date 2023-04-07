class_name GdUnitMemoryPool 
extends GdUnitSingleton

const META_PARAM := "MEMORY_POOL"


enum POOL {
	TESTSUITE,
	TESTCASE,
	EXECUTE,
	UNIT_TEST_ONLY,
	ALL,
}


var _monitors := {
	POOL.TESTSUITE : GdUnitMemMonitor.new("TESTSUITE"),
	POOL.TESTCASE : GdUnitMemMonitor.new("TESTCASE"),
	POOL.EXECUTE : GdUnitMemMonitor.new("EXECUTE"),
	POOL.UNIT_TEST_ONLY : GdUnitMemMonitor.new("UNIT_TEST_ONLY"),
}


class MemoryStore extends RefCounted:
	var _store :Array[Variant] = []
	
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			while not _store.is_empty():
				var value :Variant = _store.pop_front()
				GdUnitTools.free_instance(value)
	
	
	static func pool(p_pool :POOL) -> MemoryStore:
		var pool_name :String = POOL.keys()[p_pool]
		return GdUnitSingleton.instance(pool_name, func(): return MemoryStore.new())
	
	
	static func append(p_pool :POOL, value :Variant) -> void:
		pool(p_pool)._store.append(value)
	
	
	static func contains(p_pool :POOL, value :Variant) -> bool:
		return pool(p_pool)._store.has(value)
	
	
	static func push_front(p_pool :POOL, value :Variant) -> void:
		pool(p_pool)._store.push_front(value)
	
	
	static func release_objects(p_pool :POOL) -> void:
		var store := pool(p_pool)._store
		while not store.is_empty():
			var value :Variant = store.pop_front()
			GdUnitTools.free_instance(value)


var _current :POOL
var _orphan_detection_enabled :bool = true


func _init():
	configure(GdUnitSettings.is_verbose_orphans())


func configure(orphan_detection :bool) -> void:
	_orphan_detection_enabled = orphan_detection
	if not _orphan_detection_enabled:
		prints("!!! Reporting orphan nodes is disabled. Please check GdUnit settings.")


func set_pool(obj :Object, pool_id :POOL, reset_monitor: bool = false) -> void:
	_current = pool_id
	obj.set_meta(META_PARAM, pool_id)
	var monitor := get_monitor(pool_id)
	if reset_monitor:
		monitor.reset()
	monitor.start()


func monitor_stop() -> void:
	var monitor := get_monitor(_current)
	monitor.stop()


func free_pool() -> void:
	GdUnitMemoryPool.run_auto_free(_current)


func get_monitor(pool_id :POOL) -> GdUnitMemMonitor:
	return _monitors.get(pool_id)


func orphan_nodes() -> int:
	if _orphan_detection_enabled:
		return _monitors.get(_current).orphan_nodes()
	return 0


# register an instance to be freed when a test suite is finished
static func register_auto_free(obj, pool :POOL) -> Variant:
	# do not register on GDScriptNativeClass
	if typeof(obj) == TYPE_OBJECT and (obj as Object).is_class("GDScriptNativeClass") :
		return obj
	if obj is GDScript or obj is ScriptExtension:
		return obj
	if obj is MainLoop:
		push_error("avoid to add mainloop to auto_free queue  %s" % obj)
		return
	# only register pure objects
	if obj is GdUnitSceneRunner:
		MemoryStore.push_front(pool, obj)
	else:
		MemoryStore.append(pool, obj)
	return obj


# runs over all registered objects and frees it
static func run_auto_free(pool :POOL) -> void:
	MemoryStore.release_objects(pool)


# tests if given object is registered for auto freeing
static func is_auto_free_registered(obj, pool :POOL = POOL.ALL) -> bool:
	# only register real object values
	if not is_instance_valid(obj):
		return false
	# check all pools?
	if pool == POOL.ALL:
		return is_auto_free_registered(obj, POOL.TESTSUITE)\
			or is_auto_free_registered(obj, POOL.TESTCASE)\
			or is_auto_free_registered(obj, POOL.EXECUTE)
	# check checked a specific pool
	return MemoryStore.contains(pool, obj)
