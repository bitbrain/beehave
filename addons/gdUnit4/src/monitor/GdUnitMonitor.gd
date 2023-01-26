# GdUnit Monitoring Base Class
class_name GdUnitMonitor
extends Resource

var _id :String

# constructs new Monitor with given id
func _init(id :String):
	_id = id

# Returns the id of the monitor to uniqe identify
func id() -> String:
	return _id

# starts monitoring
func start():
	pass

# stops monitoring
func stop():
	pass
