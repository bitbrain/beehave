class_name GdUnitInit
extends GdUnitEvent


var _total_testsuites :int

func _init(total_testsuites :int,total_tests :int):
	_event_type = INIT
	_total_testsuites = total_testsuites
	_total_count = total_tests


func total_test_suites() -> int:
	return _total_testsuites

func total_tests() -> int:
	return _total_count
