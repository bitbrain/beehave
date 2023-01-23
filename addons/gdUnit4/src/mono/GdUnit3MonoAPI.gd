extends RefCounted
class_name GdUnit3MonoAPI

static func instance() :
	return null#GdUnitSingleton.get_or_create_singleton("GdUnit3MonoAPI", "res://addons/gdUnit4/src/mono/GdUnit3MonoAPI.cs")

static func create_test_suite(source_path :String, line_number :int, test_suite_path :String) -> Result:
	if not GdUnitTools.is_mono_supported():
		return  Result.error("Can't create test suite. No c# support found.")
	var result := instance().CreateTestSuite(source_path, line_number, test_suite_path) as Dictionary
	if result.has("error"):
		return Result.error(result.get("error"))
	return  Result.success(result)

static func is_test_suite(resource_path :String) -> bool:
	if not is_csharp_file(resource_path) or not GdUnitTools.is_mono_supported():
		return false
	if resource_path.is_empty():
		if GdUnitSettings.is_report_push_errors():
			push_error("Can't create test suite. Missing resource path.")
		return  false
	return instance().IsTestSuite(resource_path)

static func parse_test_suite(source_path :String) -> Node:
	if not GdUnitTools.is_mono_supported():
		if GdUnitSettings.is_report_push_errors():
			push_error("Can't create test suite. No c# support found.")
		return null
	return instance().ParseTestSuite(source_path)

static func create_executor(listener :Node) -> Node:
	if not GdUnitTools.is_mono_supported():
		return null
	return instance().Executor(listener)

static func is_csharp_file(resource_path :String) -> bool:
	var ext := resource_path.get_extension()
	return ext == "cs" and GdUnitTools.is_mono_supported()
