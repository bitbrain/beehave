class_name ChainedArgumentMatcher
extends GdUnitArgumentMatcher

var _matchers :Array


func _init(matchers :Array):
	_matchers = matchers


func is_match(arguments :Variant) -> bool:
	var arg_array := arguments as Array
	if arg_array.size() != _matchers.size():
		return false
	
	for index in arg_array.size():
		var arg :Variant = arg_array[index]
		var matcher = _matchers[index] as GdUnitArgumentMatcher
		
		if not matcher.is_match(arg):
			return false
	return true
