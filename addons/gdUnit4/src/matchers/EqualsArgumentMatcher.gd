class_name EqualsArgumentMatcher 
extends GdUnitArgumentMatcher

var _current
var _auto_deep_check_mode

func _init(current, auto_deep_check_mode := false):
	_current = current
	_auto_deep_check_mode = auto_deep_check_mode

func is_match(value) -> bool:
	# is auto deep compare mode requested
	var deep_check := deep_check_on(value)
	var case_sensitive_check := true
	return GdObjects.equals(_current, value, case_sensitive_check, deep_check)

func deep_check_on(value) -> bool:
	var deep_check := false
	if _auto_deep_check_mode and is_instance_valid(value):
		# we do deep check on all InputEvent's
		deep_check = value is InputEvent
	return deep_check
