class_name GdUnitMockFunctionDoubler
extends GdFunctionDoubler


const TEMPLATE_FUNC_WITH_RETURN_VALUE = """
	var args :Array = ["$(func_name)", $(arguments)]
	
	if $(instance)__is_prepare_return_value():
		$(instance)__save_function_return_value(args)
		return ${default_return_value}
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__do_call_real_func("$(func_name)", args):
		return $(await)super($(arguments))
	return $(instance)__get_mocked_return_value_or_default(args, ${default_return_value})

"""


const TEMPLATE_FUNC_WITH_RETURN_VOID = """
	var args :Array = ["$(func_name)", $(arguments)]
	
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		return
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__do_call_real_func("$(func_name)"):
		$(await)super($(arguments))

"""


const TEMPLATE_FUNC_VARARG_RETURN_VALUE = """
	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)", $(arguments)] + varargs
	
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		$(instance)__save_function_return_value(args)
		return ${default_return_value}
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__do_call_real_func("$(func_name)", args):
		match varargs.size():
			0: return $(await)super($(arguments))
			1: return $(await)super($(arguments), varargs[0])
			2: return $(await)super($(arguments), varargs[0], varargs[1])
			3: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2])
			4: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3])
			5: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: return $(await)super($(arguments), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
	return __get_mocked_return_value_or_default(args, ${default_return_value})

"""


func _init(push_errors :bool = false):
	super._init(push_errors)


func get_template(return_type :Variant, is_vararg :bool) -> String:
	if is_vararg:
		return TEMPLATE_FUNC_VARARG_RETURN_VALUE
	if return_type is StringName:
		return TEMPLATE_FUNC_WITH_RETURN_VALUE
	return TEMPLATE_FUNC_WITH_RETURN_VOID if (return_type == TYPE_NIL or return_type == GdObjects.TYPE_VOID) else TEMPLATE_FUNC_WITH_RETURN_VALUE
