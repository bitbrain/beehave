# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitMockImpl

################################################################################
# internal mocking stuff
################################################################################
var __working_mode :String

var __do_return_value = null
var __saved_return_values := Dictionary()

static func __instance():
	return GdUnitStaticDictionary.get_value("instance")

func __set_singleton():
	# store self need to mock static functions
	GdUnitStaticDictionary.add_value("instance", self)

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	GdUnitStaticDictionary.erase("instance")

func __is_prepare_return_value() -> bool:
	return __do_return_value != null

func __save_function_return_value(args :Array):
	__saved_return_values[args] = __do_return_value
	__do_return_value = null
	return __saved_return_values[args]

func __set_mode(mode :String):
	__working_mode = mode
	return self

func __do_return(value):
	__do_return_value = value
	return self
