class_name GdUnitTools
extends RefCounted

const GDUNIT_TEMP := "user://tmp"


static func temp_dir() -> String:
	if not DirAccess.dir_exists_absolute(GDUNIT_TEMP):
		DirAccess.make_dir_recursive_absolute(GDUNIT_TEMP)
	return GDUNIT_TEMP

static func create_temp_dir(folder_name :String) -> String:
	var new_folder = temp_dir() + "/" + folder_name
	if not DirAccess.dir_exists_absolute(new_folder):
		DirAccess.make_dir_recursive_absolute(new_folder)
	return new_folder

static func clear_tmp():
	delete_directory(GDUNIT_TEMP)
	
# Creates a new file under 
static func create_temp_file(relative_path :String, file_name :String, mode := FileAccess.WRITE) -> FileAccess:
	var file_path := create_temp_dir(relative_path) + "/" + file_name
	var file = FileAccess.open(file_path, mode)
	if file == null:
		push_error("Error creating temporary file at: %s, %s" % [file_path, error_as_string(FileAccess.get_open_error())])
	return file

static func current_dir() -> String:
	return ProjectSettings.globalize_path("res://")

static func delete_directory(path :String, only_content := false) -> void:
	var dir := DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name := "."
		while file_name != "":
			file_name = dir.get_next()
			if file_name.is_empty() or file_name == "." or file_name == "..":
				continue
			var next := path + "/" +file_name
			if dir.current_is_dir():
				delete_directory(next)
			else:
				# delete file
				var err = dir.remove(next)
				if err:
					push_error("Delete %s failed: %s" % [next, error_as_string(err)])
		if not only_content:
			var err := dir.remove(path)
			if err:
				push_error("Delete %s failed: %s" % [path, error_as_string(err)])


static func copy_file(from_file :String, to_dir :String) -> Result:
	var dir := DirAccess.open(to_dir)
	if dir != null:
		var to_file := to_dir + "/" + from_file.get_file()
		prints("Copy %s to %s" % [from_file, to_file])
		var error = dir.copy(from_file, to_file)
		if error != OK:
			return Result.error("Can't copy file form '%s' to '%s'. Error: '%s'" % [from_file, to_file, error_as_string(error)])
		return Result.success(to_file)
	return Result.error("Directory not found: " + to_dir)


static func copy_directory(from_dir :String, to_dir :String, recursive :bool = false) -> bool:
	if not DirAccess.dir_exists_absolute(from_dir):
		push_error("Source directory not found '%s'" % from_dir)
		return false
		
	# check if destination exists 
	if not DirAccess.dir_exists_absolute(to_dir):
		# create it
		var err := DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			push_error("Can't create directory '%s'. Error: %s" % [to_dir, error_as_string(err)])
			return false
	var source_dir := DirAccess.open(from_dir)
	var dest_dir := DirAccess.open(to_dir)
	if source_dir != null:
		source_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var next := "."
		
		while next != "":
			next = source_dir.get_next()
			if next == "" or next == "." or next == "..":
				continue
			var source := source_dir.get_current_dir() + "/" + next
			var dest := dest_dir.get_current_dir() + "/" + next
			if source_dir.current_is_dir():
				if recursive:
					copy_directory(source + "/", dest, recursive)
				continue
			var err = source_dir.copy(source, dest)
			if err != OK:
				push_error("Error checked copy file '%s' to '%s'" % [source, dest])
				return false
		
		return true
	else:
		push_error("Directory not found: " + from_dir)
		return false

# scans given path for sub directories by given prefix and returns the highest index numer
# e.g. <prefix_%d>
static func find_last_path_index(path :String, prefix :String) -> int:
	var dir := DirAccess.open(path)
	if dir == null:
		return 0
	var last_iteration := 0
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var next := "."
	while next != "":
		next = dir.get_next()
		if next.is_empty() or next == "." or next == "..":
			continue
		if next.begins_with(prefix):
			var iteration := next.split("_")[1].to_int()
			if iteration > last_iteration:
				last_iteration = iteration
	return last_iteration

static func delete_path_index_lower_equals_than(path :String, prefix :String, index :int) -> int:
	var dir := DirAccess.open(path)
	if dir == null:
		return 0
	var deleted := 0
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var next := "."
	while next != "":
		next = dir.get_next()
		if next.is_empty() or next == "." or next == "..":
			continue
		if next.begins_with(prefix):
			var current_index := next.split("_")[1].to_int()
			if current_index <= index:
				deleted += 1
				delete_directory(path + "/" + next)
	return deleted


static func scan_dir(path :String) -> PackedStringArray:
	var dir := DirAccess.open(path)
	if dir == null or not dir.dir_exists(path):
		return PackedStringArray()
	var content := PackedStringArray()
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var next := "."
	while next != "":
		next = dir.get_next()
		if next.is_empty() or next == "." or next == "..":
			continue
		content.append(next)
	return content

static func resource_as_array(resource_path :String) -> PackedStringArray:
	var file := FileAccess.open(resource_path, FileAccess.READ)
	if file == null:
		push_error("ERROR: Can't read resource '%s'. %s" % [resource_path, error_as_string(FileAccess.get_open_error())])
		return PackedStringArray()
	var file_content := PackedStringArray()
	while not file.eof_reached():
		file_content.append(file.get_line())
	return file_content

static func resource_as_string(resource_path :String) -> String:
	var file := FileAccess.open(resource_path, FileAccess.READ)
	if file == null:
		push_error("ERROR: Can't read resource '%s'. %s" % [resource_path, error_as_string(FileAccess.get_open_error())])
		return ""
	return file.get_as_text(true)


static func normalize_text(text :String) -> String:
	return text.replace("\r", "");


static func richtext_normalize(input :String) -> String:
	return GdUnitSingleton.instance("regex_richtext", func _regex_richtext() -> RegEx:
		return GdUnitTools.to_regex("\\[/?(b|color|bgcolor|right|table|cell).*?\\]") ).sub(input, "", true)


static func max_length(left, right) -> int:
	var ls = str(left).length()
	var rs = str(right).length()
	return rs if ls < rs else ls


static func to_regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err != OK:
		push_error("Can't compiling regx '%s'.\n ERROR: %s" % [pattern, GdUnitTools.error_as_string(err)])
	return regex


static func prints_verbose(message :String) -> void:
	if OS.is_stdout_verbose():
		prints(message)


static func free_instance(instance :Variant) -> bool:
	if instance is Array:
		for element in instance:
			free_instance(element)
		instance.clear()
		return true
	# do not free an already freed instance
	if not is_instance_valid(instance):
		return false
	# do not free a class refernece
	if typeof(instance) == TYPE_OBJECT and (instance as Object).is_class("GDScriptNativeClass"):
		return false
	if is_instance_valid(instance) and instance is RefCounted:
		instance.notification(Object.NOTIFICATION_PREDELETE)
		return true
	else:
			# is instance already freed?
		if not is_instance_valid(instance) or ClassDB.class_get_property(instance, "new"):
			return false
		release_double(instance)
		#release_connections(instance)
		if instance is Timer:
			instance.stop()
			#instance.queue_free()
			instance.call_deferred("free")
			return true
		instance.free()
		return !is_instance_valid(instance)


static func _release_connections(instance :Object):
	if is_instance_valid(instance):
		# disconnect from all connected signals to force freeing, otherwise it ends up in orphans
		for connection in instance.get_incoming_connections():
			var signal_ :Signal = connection["signal"]
			var callable_ :Callable = connection["callable"]
			#prints(instance, connection)
			#prints("signal", signal_.get_name(), signal_.get_object())
			#prints("callable", callable_.get_object())
			if instance.has_signal(signal_.get_name()) and instance.is_connected(signal_.get_name(), callable_):
				#prints("disconnect signal", signal_.get_name(), callable_)
				instance.disconnect(signal_.get_name(), callable_)
	release_timers()


static func release_timers():
	# we go the new way to hold all gdunit timers in group 'GdUnitTimers'
	for node in Engine.get_main_loop().root.get_children():
		if node.is_in_group("GdUnitTimers"):
			#prints("found gdunit timer artifact", node, is_instance_valid(node))
			if is_instance_valid(node):
				node.stop()
				node.free()


# the finally cleaup unfreed resources and singletons
static func dispose_all():
	release_timers()
	GdUnitSignals.dispose()
	GdUnitSingleton.dispose()


# if instance an mock or spy we need manually freeing the self reference
static func release_double(instance :Object) -> void:
	if instance.has_method("__release_double"):
		instance.call("__release_double")


# test is Godot mono running
static func is_mono_supported() -> bool:
	return ClassDB.class_exists("CSharpScript")


static func make_qualified_path(path :String) -> String:
	if not path.begins_with("res://"):
		if path.begins_with("//"):
			return path.replace("//", "res://")
		if path.begins_with("/"):
			return "res:/" + path
	return path

static func error_as_string(error_number :int) -> String:
	return error_string(error_number)
	
static func clear_push_errors() -> void:
	var runner = Engine.get_meta("GdUnitRunner")
	if runner != null:
		runner.clear_push_errors()

static func register_expect_interupted_by_timeout(test_suite :Node, test_case_name :String) -> void:
	var test_case = test_suite.find_child(test_case_name, false, false)
	test_case.expect_to_interupt()

static func append_array(array, append :Array) -> void:
	var major :int = Engine.get_version_info()["major"]
	var minor :int = Engine.get_version_info()["minor"]
	if major >= 3 and minor >= 3:
		array.append_array(append)
	else:
		for element in append:
			array.append(element)


static func extract_zip(zip_package :String, dest_path :String) -> Result:
	var zip: ZIPReader = ZIPReader.new()
	var err := zip.open(zip_package)
	if err != OK:
		return Result.error("Extracting `%s` failed! Please collect the error log and report this. Error Code: %s" % [zip_package, err])
	var zip_entries: PackedStringArray = zip.get_files()
	# Get base path and step over archive folder
	var archive_path = zip_entries[0]
	zip_entries.remove_at(0)
	
	for zip_entry in zip_entries:
		var new_file_path: String = dest_path + "/" + zip_entry.replace(archive_path, "")
		if zip_entry.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(new_file_path)
			continue
		var file: FileAccess = FileAccess.open(new_file_path, FileAccess.WRITE)
		file.store_buffer(zip.read_file(zip_entry))
	zip.close()
	return Result.success(dest_path)
