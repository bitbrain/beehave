class_name GdUnitSpyFunctionDoubler 
extends GdFunctionDoubler


const TEMPLATE_RETURN_VARIANT = """
	var args :Array = ["$(func_name)", $(arguments)]
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__do_call_real_func("$(func_name)"):
		return $(await)super($(arguments))
	return ${default_return_value}

"""


const TEMPLATE_RETURN_VOID = """
	var args :Array = ["$(func_name)", $(arguments)]
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__do_call_real_func("$(func_name)"):
		$(await)super($(arguments))

"""


const TEMPLATE_RETURN_VOID_VARARG = """
	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)", $(arguments)] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	$(await)$(instance)__call_func("$(func_name)", [$(arguments)] + varargs)

"""


const TEMPLATE_RETURN_VARIANT_VARARG = """
	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)", $(arguments)] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	return $(await)$(instance)__call_func("$(func_name)", [$(arguments)] + varargs)

"""


func _init(push_errors :bool = false):
	super._init(push_errors)


func get_template(return_type :Variant, is_vararg :bool) -> String:
	if is_vararg:
		return TEMPLATE_RETURN_VOID_VARARG if return_type == TYPE_NIL else TEMPLATE_RETURN_VARIANT_VARARG
	if return_type is StringName:
		return TEMPLATE_RETURN_VARIANT
	return TEMPLATE_RETURN_VOID if (return_type == TYPE_NIL or return_type == GdObjects.TYPE_VOID) else TEMPLATE_RETURN_VARIANT
