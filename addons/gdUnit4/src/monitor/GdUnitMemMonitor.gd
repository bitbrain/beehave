class_name GdUnitMemMonitor
extends GdUnitMonitor

var _orphan_nodes_start :int
var _orphan_nodes_end :int
var _orphan_total :int

func _init(name :String = ""):
	super("MemMonitor:" + name)
	_orphan_nodes_start = 0
	_orphan_nodes_end = 0
	_orphan_total = 0

func reset():
	_orphan_total = 0

func start():
	_orphan_nodes_start = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func stop():
	_orphan_nodes_end = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_orphan_total += _orphan_nodes_end - _orphan_nodes_start

func orphan_nodes() -> int:
	return _orphan_total

