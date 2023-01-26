@tool
extends Window

const EAXAMPLE_URL := "https://github.com/MikeSchulze/gdUnit4-examples/archive/refs/heads/master.zip"
const GdUnitUpdateClient = preload("res://addons/gdUnit4/src/update/GdUnitUpdateClient.gd")

@onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient
@onready var _version_label :RichTextLabel = $v/MarginContainer/GridContainer/PanelContainer/Panel/CenterContainer2/version
@onready var _btn_install :Button = $v/MarginContainer/GridContainer/PanelContainer/VBoxContainer/btn_install_examples
@onready var _progress_bar :ProgressBar = $v/MarginContainer2/HBoxContainer/ProgressBar
@onready var _progress_text :Label = $v/MarginContainer2/HBoxContainer/ProgressBar/Label
@onready var _properties_template :Node = $property_template
@onready var _properties_common :Node = $v/MarginContainer/GridContainer/Properties/Common/VBoxContainer
@onready var _properties_report :Node = $v/MarginContainer/GridContainer/Properties/Report

var _font_size :int


func _ready():
	GdUnit4Version.init_version_label(_version_label)
	_font_size = GdUnitFonts.init_fonts(_version_label)
	setup_common_properties(_properties_common, GdUnitSettings.COMMON_SETTINGS)
	setup_common_properties(_properties_report, GdUnitSettings.REPORT_SETTINGS)
	await get_tree().process_frame
	popup_centered_ratio(.75)


func _sort_by_key(left :GdUnitProperty, right :GdUnitProperty) -> bool:
	return left.name() < right.name()


func setup_common_properties(properties_parent :Node, property_category) -> void:
	var category_properties := GdUnitSettings.list_settings(property_category)
	# sort by key
	category_properties.sort_custom(Callable(self, "_sort_by_key"))
	var theme := Theme.new()
	theme.set_constant("h_separation", "GridContainer", 12)
	var last_category := "!"
	var min_size_overall := 0
	for p in category_properties:
		var min_size := 0
		var grid := GridContainer.new()
		grid.columns = 4
		grid.theme = theme
		var property : GdUnitProperty = p
		var current_category = property.category()
		if current_category != last_category:
			var sub_category :Node = _properties_template.get_child(3).duplicate()
			sub_category.get_child(0).text = current_category.capitalize()
			sub_category.custom_minimum_size.y = _font_size + 16
			properties_parent.add_child(sub_category)
			last_category = current_category
		# property name
		var label :Label = _properties_template.get_child(0).duplicate()
		label.text = _to_human_readable(property.name())
		label.custom_minimum_size = Vector2(_font_size * 20, 0)
		grid.add_child(label)
		min_size += label.size.x
		
		# property reset btn
		var reset_btn :Button = _properties_template.get_child(1).duplicate()
		reset_btn.icon = _get_btn_icon("Reload")
		reset_btn.disabled = property.value() == property.default()
		grid.add_child(reset_btn)
		min_size += reset_btn.size.x
		
		# property type specific input element
		var input :Node = _create_input_element(property, reset_btn)
		input.custom_minimum_size = Vector2(_font_size * 15, 0)
		grid.add_child(input)
		min_size +=  input.size.x
		reset_btn.connect("pressed", Callable(self, "_on_btn_property_reset_pressed").bind(property, input, reset_btn))
		# property help text
		var info :Node = _properties_template.get_child(2).duplicate()
		info.text = property.help()
		grid.add_child(info)
		min_size += info.text.length() * _font_size
		if min_size_overall < min_size:
			min_size_overall = min_size
		properties_parent.add_child(grid)
	properties_parent.custom_minimum_size.x = min_size_overall


func _create_input_element(property: GdUnitProperty, reset_btn :Button) -> Node:
	if property.is_selectable_value():
		var options := OptionButton.new()
		options.alignment = HORIZONTAL_ALIGNMENT_CENTER
		var values_set := Array(property.value_set())
		for value in values_set:
			options.add_item(value)
		options.connect("item_selected", Callable(self, "_on_option_selected").bind(property, reset_btn))
		options.select(property.value())
		return options
	if property.type() == TYPE_BOOL: 
		var check_btn := CheckButton.new()
		check_btn.connect("toggled", Callable(self, "_on_property_text_changed").bind(property, reset_btn))
		check_btn.button_pressed = property.value()
		return check_btn
	if property.type() in [TYPE_INT, TYPE_STRING]:
		var input := LineEdit.new()
		input.connect("text_changed", Callable(self, "_on_property_text_changed").bind(property, reset_btn))
		input.set_context_menu_enabled(false)
		input.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		input.set_expand_to_text_length_enabled(true)
		input.text = str(property.value())
		return input
	return Control.new()


func _to_human_readable(value :String) -> String:
	return value.split("/")[-1].capitalize()


func _get_btn_icon(name :String) -> Texture2D:
	var editor :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	if editor:
		var editiorTheme := editor.get_editor_interface().get_base_control().theme
		return editiorTheme.get_icon(name, "EditorIcons")
	return null


func _install_examples() -> void:
	_init_progress(5)
	update_progress("Downloading examples")
	await get_tree().process_frame
	var tmp_path := GdUnitTools.create_temp_dir("download")
	var zip_file := tmp_path + "/examples.zip"
	var response :GdUnitUpdateClient.HttpResponse = await _update_client.request_zip_package(EAXAMPLE_URL, zip_file)
	if response.code() != 200:
		push_warning("Examples cannot be retrieved from GitHub! \n Error code: %d : %s" % [response.code(), response.response()])
		update_progress("Install examples failed! Try it later again.")
		await get_tree().create_timer(3).timeout
		stop_progress()
		return
	# extract zip to tmp
	update_progress("Install examples into project")
	var result := GdUnitTools.extract_zip(zip_file, "res://gdUnit4-examples/")
	if result.is_error():
		update_progress("Install examples failed! %s" % result.error_message())
		await get_tree().create_timer(3).timeout
		stop_progress()
		return
	update_progress("Refresh project")
	await rescan(true)
	update_progress("Examples successfully installed")
	await get_tree().create_timer(3).timeout
	stop_progress()


func rescan(update_scripts :bool = false) -> void:
	await get_tree().idle_frame
	var plugin := EditorPlugin.new()
	var fs := plugin.get_editor_interface().get_resource_filesystem()
	fs.scan_sources()
	while fs.is_scanning():
		await get_tree().create_timer(1).timeout
	if update_scripts:
		plugin.get_editor_interface().get_resource_filesystem().update_script_classes()
	plugin.free()


func _on_btn_report_bug_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit4/issues/new?assignees=MikeSchulze&labels=bug&template=bug_report.md&title=")


func _on_btn_request_feature_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit4/issues/new?assignees=MikeSchulze&labels=enhancement&template=feature_request.md&title=")


func _on_btn_install_examples_pressed():
	_btn_install.disabled = true
	await _install_examples()
	_btn_install.disabled = false


func _on_btn_close_pressed():
	hide()


func _on_btn_property_reset_pressed(property: GdUnitProperty, input :Node, reset_btn :Button):
	if input is CheckButton:
		input.button_pressed = property.default()
	elif input is LineEdit:
		input.text = str(property.default())
		# we have to update manually for text input fields because of no change event is emited
		_on_property_text_changed(property.default(), property, reset_btn)
	elif input is OptionButton:
		input.select(0)
		_on_option_selected(0, property, reset_btn)


func _on_property_text_changed(new_value, property: GdUnitProperty, reset_btn :Button):
	property.set_value(new_value)
	reset_btn.disabled = property.value() == property.default()
	GdUnitSettings.update_property(property)


func _on_option_selected(index :int, property: GdUnitProperty, reset_btn :Button):
	property.set_value(index)
	reset_btn.disabled = property.value() == property.default()
	GdUnitSettings.update_property(property)


func _init_progress(max_value : int) -> void:
	_progress_bar.visible = true
	_progress_bar.max_value = max_value
	_progress_bar.value = 0


func _progress() -> void:
	_progress_bar.value += 1


func stop_progress() -> void:
	_progress_bar.visible = false


func update_progress(message :String) -> void:
	_progress_text.text = message
	_progress_bar.value += 1
	prints(message)
