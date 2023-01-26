class_name ChainedArgumentMatcher
extends GdUnitArgumentMatcher

var _matchers :Array

func _init(matchers :Array):
	_matchers = matchers

func is_match(arguments :Array) -> bool:
	if arguments.size() != _matchers.size():
		return false
	
	for index in arguments.size():
		var arg = arguments[index]
		var matcher = _matchers[index] as GdUnitArgumentMatcher
		
		if not matcher.is_match(arg):
			return false
	return true
