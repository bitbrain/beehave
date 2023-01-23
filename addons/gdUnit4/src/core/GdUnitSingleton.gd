################################################################################
# Provides access to a global accessible singleton 
# 
# This is a workarount to the existing auto load singleton because of some bugs 
# around plugin handling 
################################################################################
class_name GdUnitSingleton
extends RefCounted


static func instance(name :String, clazz :Callable) -> Variant:
	if Engine.has_meta(name):
		return Engine.get_meta(name)
	var singleton := clazz.call()
	Engine.set_meta(name, singleton)
	GdUnitTools.prints_verbose("Register singleton '%s:%s'" % [name, singleton])
	var singletons := Engine.get_meta("GdUnitSingeltons", PackedStringArray())
	singletons.append(name)
	Engine.set_meta("GdUnitSingeltons", singletons)
	return singleton


static func dispose() -> void:
	GdUnitTools.prints_verbose("Cleanup singleton references")
	var singletons := Engine.get_meta("GdUnitSingeltons", PackedStringArray())
	for singleton in singletons:
		var instance := Engine.get_meta(singleton)
		GdUnitTools.prints_verbose("Free singeleton '%s:%s'" % [singleton, instance])
		GdUnitTools.free_instance(instance)
		Engine.remove_meta(singleton)
	Engine.remove_meta("GdUnitSingeltons")
