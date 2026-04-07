
################################################################################
# internal mocking stuff
################################################################################
const __INSTANCE_ID = "${instance_id}"
const __SOURCE_CLASS = "${source_class}"

var __working_mode := GdUnitMock.RETURN_DEFAULTS
var __excluded_methods :PackedStringArray = []
var __do_return_value :Variant = null
var __prepare_return_value := false

#{ <func_name> = {
#		<func_args> = <return_value>
#	}
#}
var __mocked_return_values := Dictionary()


static func __instance() -> Object:
	return Engine.get_meta(__INSTANCE_ID)


func _notification(what :int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if Engine.has_meta(__INSTANCE_ID):
			Engine.remove_meta(__INSTANCE_ID)


func __instance_id() -> String:
	return __INSTANCE_ID


func __set_singleton() -> void:
	# store self need to mock static functions
	Engine.set_meta(__INSTANCE_ID, self)


func __release_double() -> void:
	# we need to release the self reference manually to prevent orphan nodes
	Engine.remove_meta(__INSTANCE_ID)


func __is_prepare_return_value() -> bool:
	return __prepare_return_value


func __sort_by_argument_matcher(left_args :Array, _right_args :Array) -> bool:
	for index in left_args.size():
		var larg :Variant = left_args[index]
		if larg is GdUnitArgumentMatcher:
			return false
	return true


# we need to sort by matcher arguments so that they are all at the end of the list
func __sort_dictionary(unsorted_args :Dictionary) -> Dictionary:
	# only need to sort if contains more than one entry
	if unsorted_args.size() <= 1:
		return unsorted_args
	var sorted_args := unsorted_args.keys()
	sorted_args.sort_custom(__sort_by_argument_matcher)
	var sorted_result := {}
	for index in sorted_args.size():
		var key :Variant = sorted_args[index]
		sorted_result[key] = unsorted_args[key]
	return sorted_result


func __save_function_return_value(args :Array) -> void:
	var func_name :String = args[0]
	var func_args :Array = args.slice(1)
	var mocked_return_value_by_args :Dictionary = __mocked_return_values.get(func_name, {})
	mocked_return_value_by_args[func_args] = __do_return_value
	__mocked_return_values[func_name] = __sort_dictionary(mocked_return_value_by_args)
	__do_return_value = null
	__prepare_return_value = false


func __is_mocked_args_match(func_args :Array, mocked_args :Array) -> bool:
	var is_matching := false
	for index in mocked_args.size():
		var args :Variant = mocked_args[index]
		if func_args.size() != args.size():
			continue
		is_matching = true
		for arg_index in func_args.size():
			var func_arg :Variant = func_args[arg_index]
			var mock_arg :Variant = args[arg_index]
			if mock_arg is GdUnitArgumentMatcher:
				is_matching = is_matching and mock_arg.is_match(func_arg)
			else:
				is_matching = is_matching and typeof(func_arg) == typeof(mock_arg) and func_arg == mock_arg
			if not is_matching:
				break
		if is_matching:
			break
	return is_matching


func __get_mocked_return_value_or_default(args :Array, default_return_value :Variant) -> Variant:
	var func_name :String = args[0]
	if not __mocked_return_values.has(func_name):
		return default_return_value
	var func_args :Array = args.slice(1)
	var mocked_args :Array = __mocked_return_values.get(func_name).keys()
	for index in mocked_args.size():
		var margs :Variant = mocked_args[index]
		if __is_mocked_args_match(func_args, [margs]):
			return __mocked_return_values[func_name][margs]
	return default_return_value


func __set_script(script :GDScript) -> void:
	super.set_script(script)


func __set_mode(working_mode :String) -> Object:
	__working_mode = working_mode
	return self


func __do_call_real_func(func_name :String, func_args := []) -> bool:
	var is_call_real_func := __working_mode == GdUnitMock.CALL_REAL_FUNC  and not __excluded_methods.has(func_name)
	# do not call real funcions for mocked functions
	if is_call_real_func and __mocked_return_values.has(func_name):
		var args :Array = func_args.slice(1)
		var mocked_args :Array = __mocked_return_values.get(func_name).keys()
		return not __is_mocked_args_match(args, mocked_args)
	return is_call_real_func


func __exclude_method_call(exluded_methods :PackedStringArray) -> void:
	__excluded_methods.append_array(exluded_methods)


func __do_return(return_value :Variant) -> Object:
	__do_return_value = return_value
	__prepare_return_value = true
	return self
