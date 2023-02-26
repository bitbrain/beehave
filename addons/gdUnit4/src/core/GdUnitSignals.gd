class_name GdUnitSignals
extends RefCounted

signal gdunit_client_connected(client_id :int)
signal gdunit_client_disconnected(client_id :int)
signal gdunit_client_terminated()

signal gdunit_event(event :GdUnitEvent)
signal gdunit_event_debug(event :GdUnitEvent)
signal gdunit_add_test_suite(test_suite :GdUnitTestSuiteDto)
signal gdunit_message(message :String)
signal gdunit_report(report :GdUnitReport)
signal gdunit_set_test_failed(is_failed :bool)


const META_KEY := "GdUnitSignals"


static func instance() -> GdUnitSignals:
	if Engine.has_meta(META_KEY):
		return Engine.get_meta(META_KEY)
	var instance := GdUnitSignals.new()
	Engine.set_meta(META_KEY, instance)
	return instance


static func dispose() -> void:
	Engine.remove_meta(META_KEY)
