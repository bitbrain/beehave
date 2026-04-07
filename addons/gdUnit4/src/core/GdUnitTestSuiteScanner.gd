class_name GdUnitTestSuiteScanner
extends RefCounted

const TEST_FUNC_TEMPLATE ="""

func test_${func_name}() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()
"""


# we exclude the gdunit source directorys by default
const exclude_scan_directories = [
	"res://addons/gdUnit4/bin",
	"res://addons/gdUnit4/src",
	"res://reports"]


var _script_parser := GdScriptParser.new()
var _extends_test_suite_classes := Array()
var _expression_runner := GdUnitExpressionRunner.new()


func scan_testsuite_classes() -> void:
	# scan and cache extends GdUnitTestSuite by class name an resource paths
	_extends_test_suite_classes.append("GdUnitTestSuite")
	if ProjectSettings.has_setting("_global_script_classes"):
		var script_classes:Array = ProjectSettings.get_setting("_global_script_classes") as Array
		for element in script_classes:
			var script_meta = element as Dictionary
			if script_meta["base"] == "GdUnitTestSuite":
				_extends_test_suite_classes.append(script_meta["class"])


func scan(resource_path :String) -> Array[Node]:
	scan_testsuite_classes()
	# if single testsuite requested
	if FileAccess.file_exists(resource_path):
		var test_suite := _parse_is_test_suite(resource_path)
		if test_suite:
			return [test_suite]
	var base_dir := DirAccess.open(resource_path)
	if base_dir == null:
			prints("Given directory or file does not exists:", resource_path)
			return []
	return _scan_test_suites(base_dir, [])


func _scan_test_suites(dir :DirAccess, collected_suites :Array[Node]) -> Array[Node]:
	if exclude_scan_directories.has(dir.get_current_dir()):
		return collected_suites
	prints("Scanning for test suites in:", dir.get_current_dir())
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name := dir.get_next()
	while file_name != "":
		var resource_path = GdUnitTestSuiteScanner._file(dir, file_name)
		if dir.current_is_dir():
			var sub_dir := DirAccess.open(resource_path)
			if sub_dir != null:
				_scan_test_suites(sub_dir, collected_suites)
		else:
			var time = LocalTime.now()
			var test_suite := _parse_is_test_suite(resource_path)
			if test_suite:
				collected_suites.append(test_suite)
			if OS.is_stdout_verbose() and time.elapsed_since_ms() > 300:
				push_warning("Scanning of test-suite '%s' took more than 300ms: " % resource_path, time.elapsed_since())
		file_name = dir.get_next()
	return collected_suites


static func _file(dir :DirAccess, file_name :String) -> String:
	var current_dir := dir.get_current_dir()
	if current_dir.ends_with("/"):
		return current_dir + file_name
	return current_dir + "/" + file_name


func _parse_is_test_suite(resource_path :String) -> Node:
	if not GdUnitTestSuiteScanner._is_script_format_supported(resource_path):
		return null
	if GdUnit4CSharpApiLoader.is_test_suite(resource_path):
		return GdUnit4CSharpApiLoader.parse_test_suite(resource_path)
	var script :Script = ResourceLoader.load(resource_path)
	if not GdObjects.is_test_suite(script):
		return null
	if GdObjects.is_gd_script(script):
		return _parse_test_suite(script)
	return null


static func _is_script_format_supported(resource_path :String) -> bool:
	var ext := resource_path.get_extension()
	if ext == "gd":
		return true
	return GdUnit4CSharpApiLoader.is_csharp_file(resource_path)


func _parse_test_suite(script :GDScript) -> GdUnitTestSuite:
	var test_suite = script.new()
	test_suite.set_name(GdUnitTestSuiteScanner.parse_test_suite_name(script))
	# find all test cases as array of names
	var test_case_names := _extract_test_case_names(script)
	# add test cases to test suite and parse test case line nummber
	_parse_and_add_test_cases(test_suite, script, test_case_names)
	# not all test case parsed?
	# we have to scan the base class to
	if not test_case_names.is_empty():
		var base_script :GDScript = test_suite.get_script().get_base_script()
		while base_script is GDScript:
			# do not parse testsuite itself
			if base_script.resource_path.find("GdUnitTestSuite") == -1:
				_parse_and_add_test_cases(test_suite, base_script, test_case_names)
			base_script = base_script.get_base_script()
	return test_suite


func _extract_test_case_names(script :GDScript) -> PackedStringArray:
	var names := PackedStringArray()
	for method in script.get_script_method_list():
		var funcName :String = method["name"]
		if funcName.begins_with("test"):
			names.append(funcName)
	return names


static func parse_test_suite_name(script :Script) -> String:
	return script.resource_path.get_file().replace(".gd", "")


func _handle_test_suite_arguments(test_suite, script :GDScript, fd :GdFunctionDescriptor):
	for arg in fd.args():
		match arg.name():
			_TestCase.ARGUMENT_SKIP:
				var result = _expression_runner.execute(script, arg.value_as_string())
				if result is bool:
					test_suite.__is_skipped = result
				else:
					push_error("Test expression '%s' cannot be evaluated because it is not of type bool!" % arg.value_as_string())
			_TestCase.ARGUMENT_SKIP_REASON:
				test_suite.__skip_reason = arg.value_as_string()
			_:
				push_error("Unsuported argument `%s` found on before() at '%s'!" % [arg.name(), script.resource_path])


func _handle_test_case_arguments(test_suite, script :GDScript, fd :GdFunctionDescriptor):
	var timeout := _TestCase.DEFAULT_TIMEOUT
	var iterations := Fuzzer.ITERATION_DEFAULT_COUNT
	var seed_value := -1
	var is_skipped := false
	var skip_reason := "Unknown."
	var fuzzers :Array[GdFunctionArgument] = []
	var test := _TestCase.new()
	
	for arg in fd.args():
		# verify argument is allowed
		# is test using fuzzers?
		if arg.type() == GdObjects.TYPE_FUZZER:
			fuzzers.append(arg)
		elif arg.has_default():
			match arg.name():
				_TestCase.ARGUMENT_TIMEOUT:
					timeout = arg.default()
				_TestCase.ARGUMENT_SKIP:
					var result = _expression_runner.execute(script, arg.value_as_string())
					if result is bool:
						is_skipped = result
					else:
						push_error("Test expression '%s' cannot be evaluated because it is not of type bool!" % arg.value_as_string())
				_TestCase.ARGUMENT_SKIP_REASON:
					skip_reason = arg.value_as_string()
				Fuzzer.ARGUMENT_ITERATIONS:
					iterations = arg.default()
				Fuzzer.ARGUMENT_SEED:
					seed_value = arg.default()
	# create new test
	test.configure(fd.name(), fd.line_number(), script.resource_path, timeout, fuzzers, iterations, seed_value)
	test.skip(is_skipped, skip_reason)
	_validate_argument(fd, test)
	test_suite.add_child(test)
	# is parameterized test?
	if fd.is_parameterized():
		var test_paramaters := GdTestParameterSet.extract_test_parameters(test_suite.get_script(), fd)
		var error := GdTestParameterSet.validate(fd.args(), test_paramaters)
		if not error.is_empty():
			test.skip(true, error)
		test.set_test_parameters(test_paramaters)


func _parse_and_add_test_cases(test_suite, script :GDScript, test_case_names :PackedStringArray):
	var test_cases_to_find = Array(test_case_names)
	var functions_to_scan := test_case_names
	functions_to_scan.append("before")
	var source := _script_parser.load_source_code(script, [script.resource_path])
	var function_descriptors := _script_parser.parse_functions(source, "", [script.resource_path], functions_to_scan)
	for fd in function_descriptors:
		if fd.name() == "before":
			_handle_test_suite_arguments(test_suite, script, fd)
		if test_cases_to_find.has(fd.name()):
			_handle_test_case_arguments(test_suite, script, fd)


const TEST_CASE_ARGUMENTS = [_TestCase.ARGUMENT_TIMEOUT, _TestCase.ARGUMENT_SKIP, _TestCase.ARGUMENT_SKIP_REASON, Fuzzer.ARGUMENT_ITERATIONS, Fuzzer.ARGUMENT_SEED]

func _validate_argument(fd :GdFunctionDescriptor, test_case :_TestCase) -> void:
	if fd.is_parameterized():
		return
	for argument in fd.args():
		if argument.type() == GdObjects.TYPE_FUZZER or argument.name() in TEST_CASE_ARGUMENTS:
			continue
		test_case.skip(true, "Unknown test case argument '%s' found." % argument.name())


# converts given file name by configured naming convention
static func _to_naming_convention(file_name :String) -> String:
	var nc :int = GdUnitSettings.get_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, 0)
	match nc:
		GdUnitSettings.NAMING_CONVENTIONS.AUTO_DETECT:
			if GdObjects.is_snake_case(file_name):
				return GdObjects.to_snake_case(file_name + "Test")
			return GdObjects.to_pascal_case(file_name + "Test")
		GdUnitSettings.NAMING_CONVENTIONS.SNAKE_CASE:
			return GdObjects.to_snake_case(file_name + "Test")
		GdUnitSettings.NAMING_CONVENTIONS.PASCAL_CASE:
			return GdObjects.to_pascal_case(file_name + "Test")
	push_error("Unexpected case")
	return "-<Unexpected>-"


static func resolve_test_suite_path(source_script_path :String, test_root_folder :String = "test") -> String:
	var file_name = source_script_path.get_basename().get_file()
	var suite_name := _to_naming_convention(file_name)
	if test_root_folder.is_empty() or test_root_folder == "/":
		return source_script_path.replace(file_name, suite_name)
	
	# is user tmp
	if source_script_path.begins_with("user://tmp"):
		return normalize_path(source_script_path.replace("user://tmp", "user://tmp/" + test_root_folder)).replace(file_name, suite_name)
	
	# at first look up is the script under a "src" folder located
	var test_suite_path :String
	var src_folder = source_script_path.find("/src/")
	if src_folder != -1:
		test_suite_path = source_script_path.replace("/src/", "/"+test_root_folder+"/")
	else:
		var paths = source_script_path.split("/", false)
		# is a plugin script?
		if paths[1] == "addons":
			test_suite_path = "%s//addons/%s/%s" % [paths[0], paths[2], test_root_folder]
			# rebuild plugin path
			for index in range(3, paths.size()):
				test_suite_path += "/" + paths[index]
		else:
			test_suite_path = paths[0] + "//" + test_root_folder
			for index in range(1, paths.size()):
				test_suite_path += "/" + paths[index]
	return normalize_path(test_suite_path).replace(file_name, suite_name)


static func normalize_path(path :String) -> String:
	return path.replace("///", "/")


static func create_test_suite(test_suite_path :String, source_path :String) -> GdUnitResult:
	# create directory if not exists
	if not DirAccess.dir_exists_absolute(test_suite_path.get_base_dir()):
		var error := DirAccess.make_dir_recursive_absolute(test_suite_path.get_base_dir())
		if error != OK:
			return GdUnitResult.error("Can't create directoy  at: %s. Error code %s" % [test_suite_path.get_base_dir(), error])
	var script := GDScript.new()
	script.source_code = GdUnitTestSuiteTemplate.build_template(source_path)
	var error := ResourceSaver.save(script, test_suite_path)
	if error != OK:
		return GdUnitResult.error("Can't create test suite at: %s. Error code %s" % [test_suite_path, error])
	return GdUnitResult.success(test_suite_path)


static func get_test_case_line_number(resource_path :String, func_name :String) -> int:
	var file := FileAccess.open(resource_path, FileAccess.READ)
	if file != null:
		var script_parser := GdScriptParser.new()
		var line_number := 0
		while not file.eof_reached():
			var row := GdScriptParser.clean_up_row(file.get_line())
			line_number += 1
			# ignore comments and empty lines and not test functions
			if row.begins_with("#") || row.length() == 0 || row.find("functest") == -1:
				continue
			# abort if test case name found
			if script_parser.parse_func_name(row) == "test_" + func_name:
				return line_number
	return -1


static func add_test_case(resource_path :String, func_name :String)  -> GdUnitResult:
	var script := load(resource_path) as GDScript
	# count all exiting lines and add two as space to add new test case
	var line_number := count_lines(script) + 2
	var func_body := TEST_FUNC_TEMPLATE.replace("${func_name}", func_name)
	if Engine.is_editor_hint():
		var ep :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
		var settings := ep.get_editor_interface().get_editor_settings()
		var ident_type :int = settings.get_setting("text_editor/behavior/indent/type")
		var ident_size :int = settings.get_setting("text_editor/behavior/indent/size")
		if ident_type == 1:
			func_body = func_body.replace("	", "".lpad(ident_size, " "))
	script.source_code += func_body
	var error := ResourceSaver.save(script, resource_path)
	if error != OK:
		return GdUnitResult.error("Can't add test case at: %s to '%s'. Error code %s" % [func_name, resource_path, error])
	return GdUnitResult.success({ "path" : resource_path, "line" : line_number})


static func count_lines(script : GDScript) -> int:
	return script.source_code.split("\n").size()


static func test_suite_exists(test_suite_path :String) -> bool:
	return FileAccess.file_exists(test_suite_path)

static func test_case_exists(test_suite_path :String, func_name :String) -> bool:
	if not test_suite_exists(test_suite_path):
		return false
	var script := ResourceLoader.load(test_suite_path) as GDScript
	for f in script.get_script_method_list():
		if f["name"] == "test_" + func_name:
			return true
	return false

static func create_test_case(test_suite_path :String, func_name :String, source_script_path :String) -> GdUnitResult:
	if test_case_exists(test_suite_path, func_name):
		var line_number := get_test_case_line_number(test_suite_path, func_name)
		return GdUnitResult.success({ "path" : test_suite_path, "line" : line_number})
	
	if not test_suite_exists(test_suite_path):
		var result := create_test_suite(test_suite_path, source_script_path)
		if result.is_error():
			return result
	return add_test_case(test_suite_path, func_name)
