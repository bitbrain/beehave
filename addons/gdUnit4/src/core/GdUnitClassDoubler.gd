# A class doubler used to mock and spy checked implementations
class_name GdUnitClassDoubler
extends RefCounted

const EXCLUDE_VIRTUAL_FUNCTIONS = [
	# we have to exclude notifications because NOTIFICATION_PREDELETE is try
	# to delete already freed spy/mock resources and will result in a conflict
	"_notification",
	#"_get_property_list",
	#"_get",
	#"_set",
	#"_to_string",
	#"_ready",
	"_input",
	"_process",
	"_enter_tree",
	# https://github.com/godotengine/godot/issues/67461
	"get_name",
	"get_path",
	"duplicate",
	]

# define functions to be exclude when spy or mock checked a scene
const EXLCUDE_SCENE_FUNCTIONS = [
	# needs to exclude get/set script functions otherwise it endsup in recursive endless loop
	"set_script",
	"get_script",
	# needs to exclude otherwise verify fails checked collection arguments checked calling to string
	"_to_string",
	# _ready is not called anymore when add_child
	"_ready",
	"_input",
	"_enter_tree"
]

const EXCLUDE_FUNCTIONS = ["new", "free", "get_instance_id", "get_tree"]

# loads the doubler template
# class_info = { "class_name": <>, "class_path" : <>}
static func load_template(template :Object, class_info :Dictionary) -> PackedStringArray:
	var source_code = template.new().get_script().source_code
	var lines := GdScriptParser.to_unix_format(source_code).split("\n")
	# replace template class_name with Doubled<class> name and extends form source class
	lines.remove_at(2)
	lines.insert(2, "class_name Doubled%s" % class_info.get("class_name").replace(".", "_"))
	lines.insert(3, extends_clazz(class_info))
	
	var eol := lines.size()
	# append Object interactions stuff
	source_code = GdUnitObjectInteractionsTemplate.new().get_script().source_code
	lines.append_array(GdScriptParser.to_unix_format(source_code).split("\n"))
	# remove_at the class header from GdUnitObjectInteractionsTemplate
	lines.remove_at(eol)
	return lines

static func extends_clazz(class_info :Dictionary) -> String:
	var clazz_name :String = class_info.get("class_name")
	var clazz_path :PackedStringArray = class_info.get("class_path", [])
	# is inner class?
	if clazz_path.size() > 1:
		return "extends %s" % clazz_name
	if clazz_path.size() == 1 and clazz_path[0].ends_with(".gd"):
		return "extends '%s'" % clazz_path[0]
	return "extends %s" % clazz_name

# double all functions of given instance
static func double_functions(clazz_name :String, clazz_path :PackedStringArray, func_doubler: GdFunctionDoubler, exclude_functions :Array) -> PackedStringArray:
	var doubled_source := PackedStringArray()
	var parser := GdScriptParser.new()
	var exclude_override_functions := EXCLUDE_VIRTUAL_FUNCTIONS + EXCLUDE_FUNCTIONS + exclude_functions
	var functions := Array()
	# double script functions
	if not ClassDB.class_exists(clazz_name):
		var result := parser.parse(clazz_name, clazz_path)
		if result.is_error():
			push_error(result.error_message())
			return PackedStringArray()
		var class_descriptor :GdClassDescriptor = result.value()
		while class_descriptor != null:
			for func_descriptor in class_descriptor.functions():
				if functions.has(func_descriptor.name()) or exclude_override_functions.has(func_descriptor.name()):
					continue
				doubled_source += func_doubler.double(func_descriptor)
				functions.append(func_descriptor.name())
			class_descriptor = class_descriptor.parent()
	
	# double regular class functions
	var clazz_functions := GdObjects.extract_class_functions(clazz_name, clazz_path)
	for method in clazz_functions:
		_hotfix_invalid_method_descriptors(method)
		var func_descriptor := GdFunctionDescriptor.extract_from(method)
		if functions.has(func_descriptor.name()) or exclude_override_functions.has(func_descriptor.name()):
			continue
		functions.append(func_descriptor.name())
		doubled_source += func_doubler.double(func_descriptor)
	return doubled_source

# hot fix https://github.com/godotengine/godot/issues/67544
static func _hotfix_invalid_method_descriptors(method :Dictionary):
	if method["name"] == "get_script":
		method["return"]["type"] = GdObjects.TYPE_VARIANT
