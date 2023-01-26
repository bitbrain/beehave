@tool
class_name GdUnitInspecor
extends Panel

signal gdunit_runner_start()
signal gdunit_runner_stop()

# header
@onready var _runButton :Button = $VBoxContainer/Header/ToolBar/Tools/run

# hold is current an test running
var _is_running :bool = false
# holds if the current running tests started in debug mode
var _running_debug_mode :bool
# if no debug mode we have an process id
var _current_runner_process_id :int = 0

# holds the current connected gdUnit runner client id
var _client_id :int

var _editor_interface :EditorInterface

# the current test runner config
var _runner_config := GdUnitRunnerConfig.new()


func _ready():
	GdUnitSignals.instance().gdunit_client_connected.connect(Callable(self, "_on_client_connected"))
	GdUnitSignals.instance().gdunit_client_disconnected.connect(Callable(self, "_on_client_disconnected"))
	GdUnitSignals.instance().gdunit_event.connect(Callable(self, "_on_event"))
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin") as EditorPlugin
	_editor_interface = plugin.get_editor_interface()
	if Engine.is_editor_hint():
		_getEditorThemes(_editor_interface)
	# preload previous test execution
	_runner_config.load()
	if GdUnitSettings.is_update_notification_enabled():
		var update_tool = load("res://addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn").instantiate()
		add_child(update_tool)


func _enter_tree():
	if Engine.is_editor_hint():
		add_script_editor_context_menu()
		add_file_system_dock_context_menu()


func _exit_tree():
	if Engine.is_editor_hint():
		ScriptEditorControls.unregister_context_menu()
		EditorFileSystemControls.unregister_context_menu()


func _process(_delta):
	_check_test_run_stopped_manually()


# is checking if the user has press the editor stop scene 
func _check_test_run_stopped_manually():
	if _is_test_running_but_stop_pressed():
		if GdUnitSettings.is_verbose_assert_warnings():
			push_warning("Test Runner scene was stopped manually, force stopping the current test run!")
		_gdUnit_stop(_client_id)


func _is_test_running_but_stop_pressed():
	return _editor_interface and _running_debug_mode and _is_running and not _editor_interface.is_playing_scene()


func _getEditorThemes(interface :EditorInterface) -> void:
	if interface == null:
		return
		# example to access current theme
	var editiorTheme := interface.get_base_control().theme
	# setup inspector button icons
	#var stylebox_types :PackedStringArray = editiorTheme.get_stylebox_type_list()
	#for stylebox_type in stylebox_types:
		#prints("stylebox_type", stylebox_type)
	#	if "Tree" == stylebox_type:
	#		prints(editiorTheme.get_stylebox_list(stylebox_type))
	#var style:StyleBoxFlat = editiorTheme.get_stylebox("panel", "Tree")
	#style.bg_color = Color.RED
	var locale = interface.get_editor_settings().get_setting("interface/editor/editor_language")
	#sessions_label.add_theme_color_override("font_color", get_color("contrast_color_2", "Editor"))
	#status_label.add_theme_color_override("font_color", get_color("contrast_color_2", "Editor"))
	#no_sessions_label.add_theme_color_override("font_color", get_color("contrast_color_2", "Editor"))


# Context menu registrations ----------------------------------------------------------------------
func add_file_system_dock_context_menu() -> void:
	var is_test_suite := func is_visible(script :GDScript, is_test_suite :bool):
		if script == null:
			return true
		return GdObjects.is_test_suite(script) == is_test_suite
	var is_enabled := func is_enabled(script :GDScript):
		return !_runButton.disabled
	var run_test := func run_test(resource_paths :PackedStringArray, debug :bool):
		run_test_suites(resource_paths, debug)
	var menu := [
		GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_RUN, "Run Tests", is_test_suite.bind(true), is_enabled, run_test.bind(false)),
		GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_DEBUG, "Debug Tests", is_test_suite.bind(true), is_enabled, run_test.bind(true)),
	]
	EditorFileSystemControls.register_context_menu(menu)


func add_script_editor_context_menu():
	var is_test_suite := func is_visible(script :GDScript, is_test_suite :bool):
		return GdObjects.is_test_suite(script) == is_test_suite
	var is_enabled := func is_enabled(script :GDScript):
		return !_runButton.disabled
	var run_test := func run_test(script :Script, text_edit :TextEdit, debug :bool):
		var cursor_line := text_edit.get_caret_line()
		#run test case?
		var regex := RegEx.new()
		regex.compile("(^func[ ,\t])(test_[a-zA-Z0-9_]*)")
		var result := regex.search(text_edit.get_line(cursor_line))
		if result:
			var func_name := result.get_string(2).strip_edges()
			prints("Run test:", func_name, "debug", debug)
			if func_name.begins_with("test_"):
				run_test_case(script.resource_path, func_name, -1, debug)
				return
		# otherwise run the full test suite
		var selected_test_suites := [script.resource_path]
		run_test_suites(selected_test_suites, debug)
	var create_test := func create_test(script :Script, text_edit :TextEdit):
		var cursor_line := text_edit.get_caret_line()
		var result = GdUnitTestSuiteBuilder.create(script, cursor_line)
		if result.is_error():
			# show error dialog
			push_error("Failed to create test case: %s" % result.error_message())
			return
		var info := result.value() as Dictionary
		ScriptEditorControls.edit_script(info.get("path"), info.get("line"))
	
	var menu := [
		GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_RUN, "Run Tests", is_test_suite.bind(true), is_enabled, run_test.bind(false)),
		GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_DEBUG, "Debug Tests", is_test_suite.bind(true), is_enabled, run_test.bind(true)),
		GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.CREATE_TEST, "Create Test", is_test_suite.bind(false), is_enabled, create_test)
	]
	ScriptEditorControls.register_context_menu(menu)


func run_test_suites(test_suite_paths :PackedStringArray, debug :bool, rerun :bool=false) -> void:
	# create new runner runner_config for fresh run otherwise use saved one
	if not rerun:
		var result := _runner_config.clear()\
			.add_test_suites(test_suite_paths)\
			.save()
		if result.is_error():
			push_error(result.error_message())
			return
	_gdUnit_run(debug)


func run_test_case(test_suite_resource_path :String, test_case :String, test_param_index :int, debug :bool, rerun := false) -> void:
	# create new runner config for fresh run otherwise use saved one
	if not rerun:
		var result := _runner_config.clear()\
			.add_test_case(test_suite_resource_path, test_case, test_param_index)\
			.save()
		if result.is_error():
			push_error(result.error_message())
			return
	_gdUnit_run(debug)


func _gdUnit_run(debug :bool) -> void:
	# don't start is already running
	if _is_running:
		return
	
	grab_focus()
	show()
	# save current selected excution config
	var result := _runner_config.set_server_port(Engine.get_meta("gdunit_server_port")).save()
	if result.is_error():
		push_error(result.error_message())
		return
	_running_debug_mode = debug
	_current_runner_process_id = -1
	# before start we have to save all changes
	ScriptEditorControls.save_all_open_script()
	# wait until all changes are saved
	await get_tree().process_frame
	gdunit_runner_start.emit()
	if debug:
		_editor_interface.play_custom_scene("res://addons/gdUnit4/src/core/GdUnitRunner.tscn")
		_is_running = true
		return
	var arguments := Array()
	if OS.is_stdout_verbose():
		arguments.append("--verbose")
	arguments.append("--no-window")
	arguments.append("--path")
	arguments.append(ProjectSettings.globalize_path("res://"))
	arguments.append("res://addons/gdUnit4/src/core/GdUnitRunner.tscn")
	_current_runner_process_id = OS.create_process(OS.get_executable_path(), arguments, false);
	_is_running = true


func _gdUnit_stop(client_id :int) -> void:
	# don't stop if is already stopped
	if not _is_running:
		return
	_is_running = false
	emit_signal("gdunit_runner_stop", client_id)
	await get_tree().process_frame
	if _running_debug_mode:
		_editor_interface.stop_playing_scene()
	else: if _current_runner_process_id > 0:
		var result = OS.kill(_current_runner_process_id)
		if result != OK:
			push_error("ERROR checked stopping GdUnit Test Runner. error code: %s" % result)
	_current_runner_process_id = -1


################################################################################
# Event signal receiver
################################################################################
func _on_event(event :GdUnitEvent):
	if event.type() == GdUnitEvent.STOP:
		_gdUnit_stop(_client_id)


################################################################################
# Inspector signal receiver
################################################################################
func _on_ToolBar_run_pressed(debug :bool = false):
	_gdUnit_run(debug)


func _on_ToolBar_stop_pressed():
	_gdUnit_stop(_client_id)


func _on_MainPanel_run_testsuite(test_suite_paths :Array, debug :bool):
	run_test_suites(test_suite_paths, debug)


func _on_MainPanel_run_testcase(resource_path :String, test_case :String, test_param_index :int, debug :bool):
	run_test_case(resource_path, test_case, test_param_index, debug)


##########################################################################
# Network stuff
func _on_client_connected(client_id :int) -> void:
	_client_id = client_id


func _on_client_disconnected(client_id :int) -> void:
	# only stops is not in debug mode running and the current client
	if not _running_debug_mode and _client_id == client_id:
		_gdUnit_stop(client_id)
	_client_id = -1
