class_name GdUnitResourceDto
extends Resource

var _name :String
var _path :String

func serialize(resource) -> Dictionary:
	var serialized := Dictionary()
	serialized["name"] = resource.get_name()
	serialized["resource_path"] = resource.ResourcePath()
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	_name = data.get("name", "n.a.")
	_path = data.get("resource_path", "")
	return self

func name() -> String:
	return _name

func path() -> String:
	return _path
