# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitMockImpl

################################################################################
# internal mocking stuff
################################################################################
const __INSTANCE_ID = "${instance_id}"

var __working_mode :String
var __excluded_methods :PackedStringArray = []
var __do_return_value = null
var __saved_return_values := Dictionary()


static func __instance():
	return GdUnitStaticDictionary.get_value(__INSTANCE_ID)


func __instance_id() -> String:
	return __INSTANCE_ID


func __set_singleton():
	# store self need to mock static functions
	GdUnitStaticDictionary.add_value(__INSTANCE_ID, self)


func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	GdUnitStaticDictionary.erase(__INSTANCE_ID)


func __is_prepare_return_value() -> bool:
	return __do_return_value != null


func __save_function_return_value(args :Array):
	__saved_return_values[args] = __do_return_value
	__do_return_value = null
	return __saved_return_values[args]


func __set_script(script :GDScript) -> void:
	super.set_script(script)


func __set_mode(working_mode :String):
	__working_mode = working_mode
	return self


func __do_call_real_func(func_name :String) -> bool:
	return __working_mode == GdUnitMock.CALL_REAL_FUNC  and not __excluded_methods.has(func_name)


func __exclude_method_call(exluded_methods :PackedStringArray) -> void:
	__excluded_methods.append_array(exluded_methods)


func __do_return(return_value):
	__do_return_value = return_value
	return self
