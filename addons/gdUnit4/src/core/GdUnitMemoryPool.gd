class_name GdUnitMemoryPool 
extends RefCounted

const META_PARAM := "MEMORY_POOL"


enum POOL {
	TESTSUITE,
	TESTCASE,
	EXECUTE,
}


var _monitors := {
	POOL.TESTSUITE : GdUnitMemMonitor.new("TESTSUITE"),
	POOL.TESTCASE : GdUnitMemMonitor.new("TESTCASE"),
	POOL.EXECUTE : GdUnitMemMonitor.new("EXECUTE"),
}


const _store := {
	POOL.TESTSUITE : [],
	POOL.TESTCASE : [],
	POOL.EXECUTE : [],
}


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
	run_auto_free(_current)


func get_monitor(pool_id :POOL) -> GdUnitMemMonitor:
	return _monitors.get(pool_id)


func orphan_nodes() -> int:
	if _orphan_detection_enabled:
		return _monitors.get(_current).orphan_nodes()
	return 0


# register an instance to be freed when a test suite is finished
static func register_auto_free(obj, pool :POOL) -> Variant:
	# only register real object values
	if not obj is Object:
		return obj
	if obj is MainLoop:
		push_error("avoid to add mainloop to auto_free queue  %s" % obj)
		return
	# only register pure objects
	if obj is GdUnitSceneRunner:
		_store[pool].push_front(obj)
	else:
		_store[pool].append(obj)
	return obj


# runs over all registered objects and frees it
static func run_auto_free(pool :POOL) -> void:
	var obj_pool :Array = _store[pool]
	#prints("run_auto_free checked Pool:", pool, obj_pool.size())
	while not obj_pool.is_empty():
		var obj :Object = obj_pool.pop_front()
		GdUnitTools.free_instance(obj)


# tests if given object is registered for auto freeing
static func is_auto_free_registered(obj, pool :POOL = -1) -> bool:
	# only register real object values
	if not obj is Object:
		return false
	# check all pools?
	if pool == -1:
		return is_auto_free_registered(obj, POOL.TESTSUITE)\
			or is_auto_free_registered(obj, POOL.TESTCASE)\
			or is_auto_free_registered(obj, POOL.EXECUTE)
	# check checked a specific pool
	return _store[pool].has(obj)
