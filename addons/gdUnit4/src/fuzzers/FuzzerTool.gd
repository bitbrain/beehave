class_name FuzzerTool
extends Resource


const fuzzer_template := """
${source_code}

func __fuzzer():
	return ${fuzzer_func}
"""

static func create_fuzzer(source :GDScript, function: GdFunctionArgument) -> Fuzzer:
	var className := source.resource_path.get_file().replace(".gd", "")
	var fuzzer_func := function.value_as_string()
	var source_code := fuzzer_template\
		.replace("${source_code}", source.source_code)\
		.replace("${fuzzer_func}", fuzzer_func)\
		.replace(className, className + "extented")
	var script := GDScript.new()
	script.source_code = source_code
	var temp_dir := "res://addons/gdUnit4/.tmp"
	DirAccess.make_dir_recursive_absolute(temp_dir)
	var resource_path_ := "%s/%s" % [temp_dir, "_fuzzer_bulder%d.gd" % Time.get_ticks_msec()]
	var err := ResourceSaver.save(script, resource_path_, ResourceSaver.FLAG_BUNDLE_RESOURCES|ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	if err != OK:
		prints("Script loading error", error_string(err))
		return null
	script = ResourceLoader.load(resource_path_, "GDScript", ResourceLoader.CACHE_MODE_IGNORE);
	var instance :Object = script.new()
	instance.queue_free()
	DirAccess.remove_absolute(script.resource_path)
	if not instance.has_method("__fuzzer"):
		prints("Error", script, "Missing function '__fuzzer'")
		return null
	return instance.call("__fuzzer") as Fuzzer
