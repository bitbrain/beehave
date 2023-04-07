@tool
extends ConfirmationDialog


#@onready var _progress_panel :Control =$UpdateProgress
@onready var _progress_content :Label = $UpdateProgress/Progress/label
@onready var _progress_bar :ProgressBar = $UpdateProgress/Progress/bar


var _debug_mode := false


func init_progress(max_value : int) -> void:
	_progress_bar.max_value = max_value
	_progress_bar.value = 0


func update_progress(message :String) -> void:
	prints("..", message)
	_progress_content.text = message
	_progress_bar.value += 1
	if _debug_mode:
		await get_tree().create_timer(3).timeout
	else:
		await get_tree().process_frame


func run_update() -> void:
	get_cancel_button().disabled = true
	get_ok_button().disabled = true
	init_progress(4)
	
	await update_progress("Extract update ..")
	var zip_file := temp_dir() + "/update.zip"
	var tmp_path := create_temp_dir("update")
	var result :Variant = extract_zip(zip_file, tmp_path)
	if result == null:
		await update_progress("Update failed!")
		await get_tree().create_timer(3).timeout
		queue_free()
		return
	
	await update_progress("Deinstall GdUnit4 ..")
	disable_gdUnit()
	if not _debug_mode:
		delete_directory("res://addons/gdUnit4/")
	# give editor time to react on deleted files
	await get_tree().create_timer(3).timeout
	
	await update_progress("Install new GdUnit4 version ..")
	if _debug_mode:
		copy_directory(tmp_path, "res://debug")
	else:
		copy_directory(tmp_path, "res://")
	
	await update_progress("New GdUnit version successfully installed, Restarting Godot ...")
	enable_gdUnit()
	await get_tree().create_timer(3).timeout
	hide()
	delete_directory("res://addons/.gdunit_update")
	restart_godot()


func rescan() -> void:
	await get_tree().process_frame
	prints("Rescan Project")
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var fs := plugin.get_editor_interface().get_resource_filesystem()
	fs.scan_sources()
	fs.update_script_classes()
	fs.scan()
	while fs.is_scanning():
		prints("Rescan Project ... scan ...")
		await get_tree().create_timer(.2).timeout


func restart_godot() -> void:
	prints("Force restart Godot")
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	plugin.get_editor_interface().restart_editor(true)


func enable_gdUnit() -> void:
	var enabled_plugins := PackedStringArray()
	if ProjectSettings.has_setting("editor_plugins/enabled"):
		enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled")
	if not enabled_plugins.has("res://addons/gdUnit4/plugin.cfg"):
		enabled_plugins.append("res://addons/gdUnit4/plugin.cfg")
	ProjectSettings.set_setting("editor_plugins/enabled", enabled_plugins)
	ProjectSettings.save()


func disable_gdUnit() -> void:
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	plugin.get_editor_interface().set_plugin_enabled("gdUnit4", false)


const GDUNIT_TEMP := "user://tmp"

func temp_dir() -> String:
	if not DirAccess.dir_exists_absolute(GDUNIT_TEMP):
		DirAccess.make_dir_recursive_absolute(GDUNIT_TEMP)
	return GDUNIT_TEMP


func create_temp_dir(folder_name :String) -> String:
	var new_folder = temp_dir() + "/" + folder_name
	delete_directory(new_folder)
	if not DirAccess.dir_exists_absolute(new_folder):
		DirAccess.make_dir_recursive_absolute(new_folder)
	return new_folder


func delete_directory(path :String, only_content := false) -> void:
	var dir := DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
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
					push_error("Delete %s failed: %s" % [next, error_string(err)])
		if not only_content:
			var err := dir.remove(path)
			if err:
				push_error("Delete %s failed: %s" % [path, error_string(err)])


func copy_directory(from_dir :String, to_dir :String) -> bool:
	if not DirAccess.dir_exists_absolute(from_dir):
		push_error("Source directory not found '%s'" % from_dir)
		return false
	# check if destination exists 
	if not DirAccess.dir_exists_absolute(to_dir):
		# create it
		var err := DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			push_error("Can't create directory '%s'. Error: %s" % [to_dir, error_string(err)])
			return false
	var source_dir := DirAccess.open(from_dir)
	var dest_dir := DirAccess.open(to_dir)
	if source_dir != null:
		source_dir.list_dir_begin()
		var next := "."
		
		while next != "":
			next = source_dir.get_next()
			if next == "" or next == "." or next == "..":
				continue
			var source := source_dir.get_current_dir() + "/" + next
			var dest := dest_dir.get_current_dir() + "/" + next
			if source_dir.current_is_dir():
				copy_directory(source + "/", dest)
				continue
			var err = source_dir.copy(source, dest)
			if err != OK:
				push_error("Error checked copy file '%s' to '%s'" % [source, dest])
				return false
		return true
	else:
		push_error("Directory not found: " + from_dir)
		return false


func extract_zip(zip_package :String, dest_path :String) -> Variant:
	var zip: ZIPReader = ZIPReader.new()
	var err := zip.open(zip_package)
	if err != OK:
		push_error("Extracting `%s` failed! Please collect the error log and report this. Error Code: %s" % [zip_package, err])
		return null
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
	return dest_path


func _on_confirmed():
	await run_update()
