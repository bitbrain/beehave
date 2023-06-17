# This is a helper class to compare two objects by equals
class_name GdObjects
extends Resource

const TYPE_VOID 	= TYPE_MAX + 1000
const TYPE_VARARG 	= TYPE_MAX + 1001
const TYPE_VARIANT	= TYPE_MAX + 1002
const TYPE_FUNC 	= TYPE_MAX + 1003
const TYPE_FUZZER 	= TYPE_MAX + 1004

const TYPE_NODE 	= TYPE_MAX + 2001
# missing Godot types
const TYPE_CONTROL	= TYPE_MAX + 2002
const TYPE_CANVAS	= TYPE_MAX + 2003
const TYPE_ENUM		= TYPE_MAX + 2004


# used as default value for varargs
const TYPE_VARARG_PLACEHOLDER_VALUE = "__null__"


const TYPE_AS_STRING_MAPPINGS := {
	TYPE_NIL: "null",
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_FLOAT: "float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_VECTOR2I: "Vector2i",
	TYPE_RECT2: "Rect2",
	TYPE_RECT2I: "Rect2i",
	TYPE_VECTOR3: "Vector3",
	TYPE_VECTOR3I: "Vector3i",
	TYPE_TRANSFORM2D: "Transform2D",
	TYPE_VECTOR4: "Vector4",
	TYPE_VECTOR4I: "Vector4i",
	TYPE_PLANE: "Plane",
	TYPE_QUATERNION: "Quaternion",
	TYPE_AABB: "AABB",
	TYPE_BASIS: "Basis",
	TYPE_TRANSFORM3D: "Transform3D",
	TYPE_PROJECTION: "Projection",
	TYPE_COLOR: "Color",
	TYPE_STRING_NAME: "StringName",
	TYPE_NODE_PATH: "NodePath",
	TYPE_RID: "RID",
	TYPE_OBJECT: "Object",
	TYPE_CALLABLE: "Callable",
	TYPE_SIGNAL: "Signal",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArray",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32Array",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64Array",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32Array",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64Array",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArray",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2Array",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3Array",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArray",
	TYPE_VOID: "void",
	TYPE_VARARG: "VarArg",
	TYPE_FUNC: "Func",
	TYPE_FUZZER: "Fuzzer",
	TYPE_VARIANT: "Variant"
}


const NOTIFICATION_AS_STRING_MAPPINGS := {
	TYPE_OBJECT: {
		Object.NOTIFICATION_POSTINITIALIZE : "POSTINITIALIZE",
		Object.NOTIFICATION_PREDELETE: "PREDELETE",
		EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED: "EDITOR_SETTINGS_CHANGED",
	},
	TYPE_NODE: {
		Node.NOTIFICATION_ENTER_TREE : "ENTER_TREE",
		Node.NOTIFICATION_EXIT_TREE: "EXIT_TREE",
		Node.NOTIFICATION_MOVED_IN_PARENT: "MOVED_IN_PARENT",
		Node.NOTIFICATION_READY: "READY",
		Node.NOTIFICATION_PAUSED: "PAUSED",
		Node.NOTIFICATION_UNPAUSED: "UNPAUSED",
		Node.NOTIFICATION_PHYSICS_PROCESS: "PHYSICS_PROCESS",
		Node.NOTIFICATION_PROCESS: "PROCESS",
		Node.NOTIFICATION_PARENTED: "PARENTED",
		Node.NOTIFICATION_UNPARENTED: "UNPARENTED",
		Node.NOTIFICATION_SCENE_INSTANTIATED: "INSTANCED",
		Node.NOTIFICATION_DRAG_BEGIN: "DRAG_BEGIN",
		Node.NOTIFICATION_DRAG_END: "DRAG_END",
		Node.NOTIFICATION_PATH_RENAMED: "PATH_CHANGED",
		Node.NOTIFICATION_INTERNAL_PROCESS: "INTERNAL_PROCESS",
		Node.NOTIFICATION_INTERNAL_PHYSICS_PROCESS: "INTERNAL_PHYSICS_PROCESS",
		Node.NOTIFICATION_POST_ENTER_TREE: "POST_ENTER_TREE",
		Node.NOTIFICATION_WM_MOUSE_ENTER: "WM_MOUSE_ENTER",
		Node.NOTIFICATION_WM_MOUSE_EXIT: "WM_MOUSE_EXIT",
		Node.NOTIFICATION_APPLICATION_FOCUS_IN: "WM_FOCUS_IN",
		Node.NOTIFICATION_APPLICATION_FOCUS_OUT: "WM_FOCUS_OUT",
		#Node.NOTIFICATION_WM_QUIT_REQUEST: "WM_QUIT_REQUEST",
		Node.NOTIFICATION_WM_GO_BACK_REQUEST: "WM_GO_BACK_REQUEST",
		Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT: "WM_UNFOCUS_REQUEST",
		Node.NOTIFICATION_OS_MEMORY_WARNING: "OS_MEMORY_WARNING",
		Node.NOTIFICATION_TRANSLATION_CHANGED: "TRANSLATION_CHANGED",
		Node.NOTIFICATION_WM_ABOUT: "WM_ABOUT",
		Node.NOTIFICATION_CRASH: "CRASH",
		Node.NOTIFICATION_OS_IME_UPDATE: "OS_IME_UPDATE",
		Node.NOTIFICATION_APPLICATION_RESUMED: "APP_RESUMED",
		Node.NOTIFICATION_APPLICATION_PAUSED: "APP_PAUSED",
		Node3D.NOTIFICATION_TRANSFORM_CHANGED: "TRANSFORM_CHANGED",
		Node3D.NOTIFICATION_ENTER_WORLD: "ENTER_WORLD",
		Node3D.NOTIFICATION_EXIT_WORLD: "EXIT_WORLD",
		Node3D.NOTIFICATION_VISIBILITY_CHANGED: "VISIBILITY_CHANGED",
		Skeleton3D.NOTIFICATION_UPDATE_SKELETON: "UPDATE_SKELETON",
		CanvasItem.NOTIFICATION_DRAW: "DRAW",
		CanvasItem.NOTIFICATION_VISIBILITY_CHANGED: "VISIBILITY_CHANGED",
		CanvasItem.NOTIFICATION_ENTER_CANVAS: "ENTER_CANVAS",
		CanvasItem.NOTIFICATION_EXIT_CANVAS: "EXIT_CANVAS",
		#Popup.NOTIFICATION_POST_POPUP: "POST_POPUP",
		#Popup.NOTIFICATION_POPUP_HIDE: "POPUP_HIDE",
	},
	TYPE_CONTROL : {
		Container.NOTIFICATION_SORT_CHILDREN: "SORT_CHILDREN",
		Control.NOTIFICATION_RESIZED: "RESIZED",
		Control.NOTIFICATION_MOUSE_ENTER: "MOUSE_ENTER",
		Control.NOTIFICATION_MOUSE_EXIT: "MOUSE_EXIT",
		Control.NOTIFICATION_FOCUS_ENTER: "FOCUS_ENTER",
		Control.NOTIFICATION_FOCUS_EXIT: "FOCUS_EXIT",
		Control.NOTIFICATION_THEME_CHANGED: "THEME_CHANGED",
		#Control.NOTIFICATION_MODAL_CLOSE: "MODAL_CLOSE",
		Control.NOTIFICATION_SCROLL_BEGIN: "SCROLL_BEGIN",
		Control.NOTIFICATION_SCROLL_END: "SCROLL_END",
	}
}


enum COMPARE_MODE {
	OBJECT_REFERENCE,
	PARAMETER_DEEP_TEST
}


# prototype of better object to dictionary
static func obj2dict(obj :Object, hashed_objects := Dictionary()) -> Dictionary:
	if obj == null:
		return {}
	var clazz_name := obj.get_class()
	var dict := Dictionary()
	var clazz_path := ""
	
	if is_instance_valid(obj) and obj.get_script() != null:
		var d := inst_to_dict(obj)
		clazz_path = d["@path"]
		if d["@subpath"] != NodePath(""):
			clazz_name = d["@subpath"]
			dict["@inner_class"] = true
		else:
			clazz_name = clazz_path.get_file().replace(".gd", "")
	dict["@path"] = clazz_path
	
	for property in obj.get_property_list():
		var property_name = property["name"]
		var property_type = property["type"]
		var property_value = obj.get(property_name)
		if property_value is GDScript or property_value is Callable:
			continue
		if (property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_DEFAULT
			and not property["usage"] & PROPERTY_USAGE_CATEGORY
			and not property["usage"] == 0):
			if property_type == TYPE_OBJECT:
				# prevent recursion
				if hashed_objects.has(obj):
					dict[property_name] = str(property_value)
					continue
				hashed_objects[obj] = true
				dict[property_name] = obj2dict(property_value, hashed_objects)
			else:
				dict[property_name] = property_value
	return {"%s" % clazz_name : dict}


static func equals(obj_a, obj_b, case_sensitive :bool = false, compare_mode :COMPARE_MODE = COMPARE_MODE.PARAMETER_DEEP_TEST) -> bool:
	return _equals(obj_a, obj_b, case_sensitive, compare_mode, [], 0)


static func equals_sorted(obj_a :Array, obj_b :Array, case_sensitive :bool = false, compare_mode :COMPARE_MODE = COMPARE_MODE.PARAMETER_DEEP_TEST) -> bool:
	var a := obj_a.duplicate()
	var b := obj_b.duplicate()
	a.sort()
	b.sort()
	return equals(a, b, case_sensitive, compare_mode)


static func _equals(obj_a, obj_b, case_sensitive :bool, compare_mode :COMPARE_MODE, deep_stack, stack_depth :int ) -> bool:
	var type_a := typeof(obj_a)
	var type_b := typeof(obj_b)
	if stack_depth > 32:
		prints("stack_depth", stack_depth, deep_stack)
		push_error("GdUnit equals has max stack deep reached!")
		return false
	
	stack_depth += 1
	# fast fail is different types
	if not _is_type_equivalent(type_a, type_b):
		return false
	# is same instance
	if obj_a == obj_b:
		return true
	# handle null values
	if obj_a == null and obj_b != null:
		return false
	if obj_b == null and obj_a != null:
		return false
	
	match type_a:
		TYPE_OBJECT:
			if deep_stack.has(obj_a) or deep_stack.has(obj_b):
				return true
			deep_stack.append(obj_a)
			deep_stack.append(obj_b)
			if compare_mode == COMPARE_MODE.PARAMETER_DEEP_TEST:
				# fail fast
				if not is_instance_valid(obj_a) or not is_instance_valid(obj_b):
					return false
				if obj_a.get_class() != obj_b.get_class():
					return false
				var a = obj2dict(obj_a)
				var b = obj2dict(obj_b)
				return _equals(a, b, case_sensitive, compare_mode, deep_stack, stack_depth)
			return obj_a == obj_b
		
		TYPE_ARRAY:
			if obj_a.size() != obj_b.size():
				return false
			for index in obj_a.size():
				if not _equals(obj_a[index], obj_b[index], case_sensitive, compare_mode, deep_stack, stack_depth):
					return false
			return true
		
		TYPE_DICTIONARY:
			if obj_a.size() != obj_b.size():
				return false
			for key in obj_a.keys():
				var value_a = obj_a[key] if obj_a.has(key) else null
				var value_b = obj_b[key] if obj_b.has(key) else null
				if not _equals(value_a, value_b, case_sensitive, compare_mode, deep_stack, stack_depth):
					return false
			return true
		
		TYPE_STRING:
			if case_sensitive:
				return obj_a.to_lower() == obj_b.to_lower()
			else:
				return obj_a == obj_b
	return obj_a == obj_b


@warning_ignore("shadowed_variable_base_class")
static func notification_as_string(instance :Variant, notification :int) -> String:
	var error := "Unknown notification: '%s' at instance:  %s" % [notification, instance]
	if instance is Node:
		return NOTIFICATION_AS_STRING_MAPPINGS[TYPE_NODE].get(notification, error)
	if instance is Control:
		return NOTIFICATION_AS_STRING_MAPPINGS[TYPE_CONTROL].get(notification, error)
	return NOTIFICATION_AS_STRING_MAPPINGS[TYPE_OBJECT].get(notification, error)


static func string_to_type(value :String) -> int:
	for type in TYPE_AS_STRING_MAPPINGS.keys():
		if TYPE_AS_STRING_MAPPINGS.get(type) == value:
			return type
	return TYPE_NIL


static func to_camel_case(value :String) -> String:
	var p := to_pascal_case(value)
	if not p.is_empty():
		p[0] = p[0].to_lower()
	return p


static func to_pascal_case(value :String) -> String:
	return value.capitalize().replace(" ", "")


static func to_snake_case(value :String) -> String:
	var result = PackedStringArray()
	for ch in value:
		var lower_ch = ch.to_lower()
		if ch != lower_ch and result.size() > 1:
			result.append('_')
		result.append(lower_ch)
	return ''.join(result)


static func is_snake_case(value :String) -> bool:
	for ch in value:
		if ch == '_':
			continue
		if ch == ch.to_upper():
			return false
	return true


static func type_as_string(type :int) -> String:
	return TYPE_AS_STRING_MAPPINGS.get(type, "Variant")


static func typeof_as_string(value) -> String:
	return TYPE_AS_STRING_MAPPINGS.get(typeof(value), "Unknown type")


static func all_types() -> PackedInt32Array:
	return PackedInt32Array(TYPE_AS_STRING_MAPPINGS.keys())


static func string_as_typeof(type_name :String) -> int:
	var type = TYPE_AS_STRING_MAPPINGS.find_key(type_name)
	return type if type != null else TYPE_VARIANT


static func is_primitive_type(value) -> bool:
	return typeof(value) in [TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME, TYPE_INT, TYPE_FLOAT]


static func _is_type_equivalent(type_a, type_b) -> bool:
	# don't test for TYPE_STRING_NAME equivalenz
	if type_a == TYPE_STRING_NAME or type_b == TYPE_STRING_NAME:
		return true
	if GdUnitSettings.is_strict_number_type_compare():
		return type_a == type_b
	return (
		(type_a == TYPE_FLOAT and type_b == TYPE_INT)
		or (type_a == TYPE_INT and type_b == TYPE_FLOAT)
		or type_a == type_b)


static func is_engine_type(value :Object) -> bool:
	if value is GDScript or value is ScriptExtension:
		return false
	return value.is_class("GDScriptNativeClass")


static func is_type(value :Variant) -> bool:
	# is an build-in type
	if typeof(value) != TYPE_OBJECT:
		return false
	# is a engine class type
	if is_engine_type(value):
		return true
	# is a custom class type
	if value is GDScript and value.can_instantiate():
		return true
	return false


@warning_ignore("shadowed_global_identifier")
static func _is_same(left, right) -> bool:
	var left_type := -1 if left == null else typeof(left)
	var right_type := -1 if right == null else typeof(right)

	# if typ different can't be the same
	if left_type != right_type:
		return false
	if left_type == TYPE_OBJECT and right_type == TYPE_OBJECT:
		return left.get_instance_id() == right.get_instance_id()
	return equals(left, right)


static func is_object(value) -> bool:
	return typeof(value) == TYPE_OBJECT


static func is_script(value) -> bool:
	return is_object(value) and value is Script


static func is_test_suite(script :Script) -> bool:
	return is_gd_testsuite(script) or GdUnit3MonoAPI.is_test_suite(script.resource_path)


static func is_native_class(value) -> bool:
	return is_object(value) and is_engine_type(value)


static func is_scene(value) -> bool:
	return is_object(value) and value is PackedScene


static func is_scene_resource_path(value) -> bool:
	return value is String and value.ends_with(".tscn")


static func is_gd_script(script :Script) -> bool:
	return script is GDScript


static func is_cs_script(script :Script) -> bool:
	# we need to check by stringify name because checked non mono Godot the class CSharpScript is not available
	return str(script).find("CSharpScript") != -1


static func is_cs_test_suite(instance :Node) -> bool:
	return instance.get("IsCsTestSuite") == true


static func is_gd_testsuite(script :Script) -> bool:
	if is_gd_script(script):
		var stack := [script]
		while not stack.is_empty():
			var current := stack.pop_front() as Script
			var base := current.get_base_script() as Script
			if base != null:
				if base.resource_path.find("GdUnitTestSuite") != -1:
					return true
				stack.push_back(base)
	return false


static func is_singleton(value :Variant) -> bool:
	if not is_instance_valid(value) or is_native_class(value):
		return false
	for name in Engine.get_singleton_list():
		if value.is_class(name):
			return true
	return false


static func is_instance(value :Variant) -> bool:
	if not is_instance_valid(value) or is_native_class(value):
		return false
	if is_script(value) and value.get_instance_base_type() == "":
		return true
	if is_scene(value):
		return true
	return not value.has_method('new') and not value.has_method('instance')


# only object form type Node and attached filename
static func is_instance_scene(instance) -> bool:
	if instance is Node:
		var node := instance as Node
		return node.get_scene_file_path() != null and not node.get_scene_file_path().is_empty()
	return false


static func can_be_instantiate(obj :Variant) -> bool:
	if not obj or is_engine_type(obj):
		return false
	return obj.has_method("new")


static func create_instance(clazz) -> Result:
	match typeof(clazz):
		TYPE_OBJECT:
			# test is given clazz already an instance
			if is_instance(clazz):
				return Result.success(clazz)
			return Result.success(clazz.new())
		TYPE_STRING:
			if ClassDB.class_exists(clazz):
				if Engine.has_singleton(clazz):
					return Result.error("Not allowed to create a instance for singelton '%s'." % clazz)
				if not ClassDB.can_instantiate(clazz):
					return  Result.error("Can't instance Engine class '%s'." % clazz)
				return Result.success(ClassDB.instantiate(clazz))
			else:
				var clazz_path :String = extract_class_path(clazz)[0]
				if not FileAccess.file_exists(clazz_path):
					return Result.error("Class '%s' not found." % clazz)
				var script = load(clazz_path)
				if script != null:
					return Result.success(script.new())
				else:
					return Result.error("Can't create instance for '%s'." % clazz)
	return Result.error("Can't create instance for class '%s'." % clazz)


static func extract_class_path(clazz) -> PackedStringArray:
	var clazz_path := PackedStringArray()
	if clazz is String:
		clazz_path.append(clazz)
		return clazz_path
	if is_instance(clazz):
		# is instance a script instance?
		var script := clazz.script as GDScript
		if script != null:
			return extract_class_path(script)
		return clazz_path
	
	if clazz is GDScript:
		if not clazz.resource_path.is_empty():
			clazz_path.append(clazz.resource_path)
			return clazz_path
		# if not found we go the expensive way and extract the path form the script by creating an instance
		var arg_list := build_function_default_arguments(clazz, "_init")
		var instance = clazz.callv("new", arg_list)
		var clazz_info := inst_to_dict(instance)
		GdUnitTools.free_instance(instance)
		clazz_path.append(clazz_info["@path"])
		if clazz_info.has("@subpath"):
			var sub_path :String = clazz_info["@subpath"]
			if not sub_path.is_empty():
				var sub_paths := sub_path.split("/")
				clazz_path += sub_paths
		return clazz_path
	return clazz_path


static func extract_class_name_from_class_path(clazz_path :PackedStringArray) -> String:
	var base_clazz := clazz_path[0]
	# return original class name if engine class
	if ClassDB.class_exists(base_clazz):
		return base_clazz
	var clazz_name := to_pascal_case(base_clazz.get_basename().get_file())
	for path_index in range(1, clazz_path.size()):
		clazz_name += "." + clazz_path[path_index]
	return  clazz_name


static func extract_class_name(clazz) -> Result:
	if clazz == null:
		return Result.error("Can't extract class name form a null value.")
	
	if is_instance(clazz):
		# is instance a script instance?
		var script := clazz.script as GDScript
		if script != null:
			return extract_class_name(script)
		return Result.success(clazz.get_class())
	
	# extract name form full qualified class path
	if clazz is String:
		if ClassDB.class_exists(clazz):
			return Result.success(clazz)
		var source_sript :Script = load(clazz)
		var clazz_name = load("res://addons/gdUnit4/src/core/parse/GdScriptParser.gd").new().get_class_name(source_sript)
		return Result.success(to_pascal_case(clazz_name))
	
	if is_primitive_type(clazz):
		return Result.error("Can't extract class name for an primitive '%s'" % type_as_string(typeof(clazz)))
	
	if is_script(clazz):
		if clazz.resource_path.is_empty():
			var class_path = extract_class_name_from_class_path(extract_class_path(clazz))
			return Result.success(class_path);
		return extract_class_name(clazz.resource_path)
	
	# need to create an instance for a class typ the extract the class name
	var instance = clazz.new()
	if instance == null:
		return Result.error("Can't create a instance for class '%s'" % clazz)
	var result := extract_class_name(instance)
	GdUnitTools.free_instance(instance)
	return result


static func extract_inner_clazz_names(clazz_name :String, script_path :PackedStringArray) -> PackedStringArray:
	var inner_classes := PackedStringArray()
	
	if ClassDB.class_exists(clazz_name):
		return inner_classes
	var script :GDScript = load(script_path[0])
	var map := script.get_script_constant_map()
	for key in map.keys():
		var value = map.get(key)
		if value is GDScript:
			var class_path := extract_class_path(value)
			inner_classes.append(class_path[1])
	return inner_classes


static func extract_class_functions(clazz_name :String, script_path :PackedStringArray) -> Array:
	if ClassDB.class_get_method_list(clazz_name):
		return ClassDB.class_get_method_list(clazz_name)
	
	if not FileAccess.file_exists(script_path[0]):
		return Array()
	var script :GDScript = load(script_path[0])
	if script is GDScript:
		# if inner class on class path we have to load the script from the script_constant_map
		if script_path.size() == 2 and script_path[1] != "":
			var inner_classes := script_path[1]
			var map := script.get_script_constant_map()
			script = map[inner_classes]
		var clazz_functions :Array = script.get_method_list()
		var base_clazz :String = script.get_instance_base_type()
		if base_clazz:
			return extract_class_functions(base_clazz, script_path)
		return clazz_functions
	return Array()


# scans all registert script classes for given <clazz_name>
# if the class is public in the global space than return true otherwise false
# public class means the script class is defined by 'class_name <name>'
static func is_public_script_class(clazz_name) -> bool:
	var script_classes:Array[Dictionary] = ProjectSettings.get_global_class_list()
	for class_info in script_classes:
		if class_info.has("class"):
			if class_info["class"] == clazz_name:
				return true
	return false


static func build_function_default_arguments(script :GDScript, func_name :String) -> Array:
	var arg_list := Array()
	for func_sig in script.get_script_method_list():
		if func_sig["name"] == func_name:
			var args :Array = func_sig["args"]
			for arg in args:
				var value_type := arg["type"] as int
				var default_value = default_value_by_type(value_type)
				arg_list.append(default_value)
			return arg_list
	return arg_list


static func default_value_by_type(type :int):
	assert(type < TYPE_MAX)
	assert(type >= 0)
	
	match type:
		TYPE_NIL: return null
		TYPE_BOOL: return false
		TYPE_INT: return 0
		TYPE_FLOAT: return 0.0
		TYPE_STRING: return ""
		TYPE_VECTOR2: return Vector2.ZERO
		TYPE_VECTOR2I: return Vector2i.ZERO
		TYPE_VECTOR3: return Vector3.ZERO
		TYPE_VECTOR3I: return Vector3i.ZERO
		TYPE_VECTOR4: return Vector4.ZERO
		TYPE_VECTOR4I: return Vector4i.ZERO
		TYPE_RECT2: return Rect2()
		TYPE_RECT2I: return Rect2i()
		TYPE_TRANSFORM2D: return Transform2D()
		TYPE_PLANE: return Plane()
		TYPE_QUATERNION: return Quaternion()
		TYPE_AABB: return AABB()
		TYPE_BASIS: return Basis()
		TYPE_TRANSFORM3D: return Transform3D()
		TYPE_COLOR: return Color()
		TYPE_NODE_PATH: return NodePath()
		TYPE_RID: return RID()
		TYPE_OBJECT: return null
		TYPE_ARRAY: return []
		TYPE_DICTIONARY: return {}
		TYPE_PACKED_BYTE_ARRAY: return PackedByteArray()
		TYPE_PACKED_COLOR_ARRAY: return PackedColorArray()
		TYPE_PACKED_INT32_ARRAY: return PackedInt32Array()
		TYPE_PACKED_INT64_ARRAY: return PackedInt64Array()
		TYPE_PACKED_FLOAT32_ARRAY: return PackedFloat32Array()
		TYPE_PACKED_FLOAT64_ARRAY: return PackedFloat64Array()
		TYPE_PACKED_STRING_ARRAY: return PackedStringArray()
		TYPE_PACKED_VECTOR2_ARRAY: return PackedVector2Array()
		TYPE_PACKED_VECTOR3_ARRAY: return PackedVector3Array()
	
	push_error("Can't determine a default value for type: '%s', Please create a Bug issue and attach the stacktrace please." % type)
	return null


static func find_nodes_by_class(root: Node, cls: String, recursive: bool = false) -> Array[Node]:
	if not recursive:
		return _find_nodes_by_class_no_rec(root, cls)
	return _find_nodes_by_class(root, cls)


static func _find_nodes_by_class_no_rec(parent: Node, cls: String) -> Array[Node]:
	var result :Array[Node] = []
	for ch in parent.get_children():
		if ch.get_class() == cls:
			result.append(ch)
	return result


static func _find_nodes_by_class(root: Node, cls: String) -> Array[Node]:
	var result :Array[Node] = []
	var stack  :Array[Node] = [root]
	while stack:
		var node :Node = stack.pop_back()
		if node.get_class() == cls:
			result.append(node)
		for ch in node.get_children():
			stack.push_back(ch)
	return result
