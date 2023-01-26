class_name GdUnitSpyFunctionDoubler 
extends GdFunctionDoubler

const TEMPLATE_RETURN_VARIANT = \
"""	var args :Array = ["$(func_name)"$(args)]
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	if $(is_virtual) == false:
		return $(await)super.$(func_name)($(func_arg))
	return ${default_return_value}
"""

const TEMPLATE_RETURN_VOID = \
"""	var args :Array = ["$(func_name)"$(args)]
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	if $(is_virtual) == false:
		$(await)super.$(func_name)($(func_arg))
"""

const TEMPLATE_RETURN_VOID_VARARG =\
"""	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)"$(args)] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false:
		match varargs.size():
			0: $(await)super.$(func_name)($(func_arg))
			1: $(await)super.$(func_name)($(func_arg), varargs[0])
			2: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1])
			3: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2])
			4: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3])
			5: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: $(await)super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

const TEMPLATE_RETURN_VARIANT_VARARG =\
"""	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)"$(args)] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false:
		match varargs.size():
			0: $(await)return super.$(func_name)($(func_arg))
			1: $(await)return super.$(func_name)($(func_arg), varargs[0])
			2: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1])
			3: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2])
			4: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3])
			5: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: $(await)return super.$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
	return ${default_return_value}
"""

const TEMPLATE_RETURN_VOID_VARARG_ONLY =\
"""	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)"] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false:
		match varargs.size():
			0: $(await)super.$(func_name)()
			1: $(await)super.$(func_name)(varargs[0])
			2: $(await)super.$(func_name)(varargs[0], varargs[1])
			3: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2])
			4: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3])
			5: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

const TEMPLATE_RETURN_VARIANT_VARARG_ONLY =\
"""	var varargs :Array = __filter_vargs([$(varargs)])
	var args :Array = ["$(func_name)"] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false:
		match varargs.size():
			0: return $(await)super.$(func_name)()
			1: return $(await)super.$(func_name)(varargs[0])
			2: return $(await)super.$(func_name)(varargs[0], varargs[1])
			3: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2])
			4: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3])
			5: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: return $(await)super.$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
	return ${default_return_value}
"""

func _init(push_errors :bool = false):
	super._init(push_errors)

func get_template(return_type :int, is_vararg :bool, is_args :bool) -> String:
	if is_vararg and is_args:
		return TEMPLATE_RETURN_VOID_VARARG if return_type == TYPE_NIL else TEMPLATE_RETURN_VARIANT_VARARG
	if is_vararg and not is_args:
		return TEMPLATE_RETURN_VOID_VARARG_ONLY if return_type == TYPE_NIL else TEMPLATE_RETURN_VARIANT_VARARG_ONLY
	return TEMPLATE_RETURN_VOID if (return_type == TYPE_NIL or return_type == GdObjects.TYPE_VOID) else TEMPLATE_RETURN_VARIANT
