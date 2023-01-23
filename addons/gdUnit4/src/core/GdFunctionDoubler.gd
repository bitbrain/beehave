class_name GdFunctionDoubler
extends RefCounted

const DEFAULT_TYPED_RETURN_VALUES := {
	TYPE_NIL: "null",
	TYPE_BOOL: "false",
	TYPE_INT: "0",
	TYPE_FLOAT: "0.0",
	TYPE_STRING: "\"\"",
	TYPE_STRING_NAME: "&\"\"",
	TYPE_VECTOR2: "Vector2.ZERO",
	TYPE_VECTOR2I: "Vector2i.ZERO",
	TYPE_RECT2: "Rect2()",
	TYPE_RECT2I: "Rect2i()",
	TYPE_VECTOR3: "Vector3.ZERO",
	TYPE_VECTOR3I: "Vector3i.ZERO",
	TYPE_VECTOR4: "Vector4.ZERO",
	TYPE_VECTOR4I: "Vector4i.ZERO",
	TYPE_TRANSFORM2D: "Transform2D()",
	TYPE_PLANE: "Plane()",
	TYPE_QUATERNION: "Quaternion()",
	TYPE_AABB: "AABB()",
	TYPE_BASIS: "Basis()",
	TYPE_TRANSFORM3D: "Transform3D()",
	TYPE_PROJECTION: "Projection()",
	TYPE_COLOR: "Color()",
	TYPE_NODE_PATH: "NodePath()",
	TYPE_RID: "RID()",
	TYPE_OBJECT: "null",
	TYPE_CALLABLE: "Callable()",
	TYPE_SIGNAL: "Signal()",
	TYPE_DICTIONARY: "Dictionary()",
	TYPE_ARRAY: "Array()",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArray()",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32Array()",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64Array()",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32Array()",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64Array()",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArray()",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2Array()",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3Array()",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArray()",
}

static func default_return_value(type :int) -> String:
	if DEFAULT_TYPED_RETURN_VALUES.size() != TYPE_MAX:
		push_error("missing default definitions! Expexting %d bud is %d" % [DEFAULT_TYPED_RETURN_VALUES.size(), TYPE_MAX])
		for type_key in range(0, DEFAULT_TYPED_RETURN_VALUES.size()):
			if not DEFAULT_TYPED_RETURN_VALUES.has(type_key):
				prints("missing default definition for type", type_key)
				assert(DEFAULT_TYPED_RETURN_VALUES.has(type_key), "Missing Type default definition!")
	if DEFAULT_TYPED_RETURN_VALUES.has(type):
		return DEFAULT_TYPED_RETURN_VALUES.get(type)
	return "null"


var _push_errors :String

func _init(push_errors :bool = false):
	_push_errors = "true" if push_errors else "false"

func get_template(return_type :int, is_vararg :bool, has_args :bool) -> String:
	push_error("Must be implemented!")
	return ""

func double(func_descriptor :GdFunctionDescriptor) -> PackedStringArray:
	var func_signature := func_descriptor.typeless()
	var is_virtual := func_descriptor.is_virtual()
	var is_static := func_descriptor.is_static()
	var is_engine := func_descriptor.is_engine()
	var is_vararg := func_descriptor.is_vararg()
	var is_coroutine := func_descriptor.is_coroutine()
	var func_name := func_descriptor.name()
	var args := func_descriptor.args()
	var varargs := func_descriptor.varargs()
	var default_return_value = default_return_value(func_descriptor.return_type())
	var arg_names := extract_arg_names(args)
	var vararg_names := extract_arg_names(varargs)
	
	# save original constructor arguments
	if func_name == "_init":
		var constructor_args := ",".join(extract_constructor_args(args))
		var constructor := "func _init(%s):\n	super._init(%s)\n	pass\n" % [constructor_args, ", ".join(arg_names)]
		return constructor.split("\n")
	
	var double := func_signature + "\n"
	var func_template := get_template(func_descriptor.return_type(), is_vararg, not arg_names.is_empty())
	# fix to  unix format, this is need when the template is edited under windows than the template is stored with \r\n
	func_template = GdScriptParser.to_unix_format(func_template)
	double += func_template\
		.replace("$(args)", to_comma_separated_values(arg_names))\
		.replace("$(varargs)", ", ".join(vararg_names))\
		.replace("$(is_virtual)", str(is_virtual).to_lower()) \
		.replace("$(await)", await_is_coroutine(is_coroutine)) \
		.replace("$(func_name)", func_name )\
		.replace("$(func_arg)", ", ".join(arg_names))\
		.replace("${default_return_value}", default_return_value)\
		.replace("$(push_errors)", _push_errors)
	if is_static:
		double = double.replace("$(instance)", "__instance().")
	else:
		double = double.replace("$(instance)", "")
	return double.split("\n")

func extract_arg_names(argument_signatures :Array[GdFunctionArgument]) -> PackedStringArray:
	var arg_names := PackedStringArray()
	for arg in argument_signatures:
		arg_names.append(arg._name)
	return arg_names

static func extract_constructor_args(args :Array) -> PackedStringArray:
	var constructor_args := PackedStringArray()
	for arg in args:
		var a := arg as GdFunctionArgument
		var arg_name := a._name
		var default_value = get_default(a)
		constructor_args.append(arg_name + "=" + default_value)
	return constructor_args

static func get_default(arg :GdFunctionArgument) -> String:
	if arg.has_default():
		return arg.value_as_string()
	else:
		return default_return_value(arg.type())

static func to_comma_separated_values(values :Array) -> String:
	if values.size() == 0:
		return ""
	return ", "  + ", ".join(values)

static func await_is_coroutine(is_coroutine :bool) -> String:
	return "await " if is_coroutine else ""
	
