@tool
extends Window

signal request_completed(response)

const GdMarkDownReader = preload("res://addons/gdUnit4/src/update/GdMarkDownReader.gd")
const GdUnitUpdateClient = preload("res://addons/gdUnit4/src/update/GdUnitUpdateClient.gd")
const spinner_icon := "res://addons/gdUnit4/src/ui/assets/spinner.tres"

@onready var _md_reader :GdMarkDownReader = GdMarkDownReader.new()
@onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient
@onready var _header :Label = $Panel/GridContainer/PanelContainer/header
@onready var _update_button :Button = $Panel/GridContainer/Panel/HBoxContainer/update
@onready var _close_button :Button = $Panel/GridContainer/Panel/HBoxContainer/close
@onready var _content :RichTextLabel = $Panel/GridContainer/PanelContainer2/ScrollContainer/MarginContainer/content

var _debug_mode := false

var _patcher :GdUnitPatcher = GdUnitPatcher.new()
var _current_version := GdUnit4Version.current()
var _available_versions :Array
var _download_zip_url :String


func _ready():
	_update_button.disabled = true
	_md_reader.set_http_client(_update_client)
	GdUnitFonts.init_fonts(_content)
	await request_releases()


func request_releases() -> void:
	if _debug_mode:
		_header.text = "A new version 'v4.1.0_debug' is available"
		await show_update()
		return
	var response :GdUnitUpdateClient.HttpResponse = await _update_client.request_latest_version()
	if response.code() != 200:
		push_warning("Update information cannot be retrieved from GitHub! \n %s" % response.response())
		return
	var latest_version := extract_latest_version(response)
	# if same version exit here no update need
	if latest_version.is_greater(_current_version):
		_patcher.scan(_current_version)
		_header.text = "A new version '%s' is available" % latest_version
		_download_zip_url = extract_zip_url(response)
		await show_update()


func _colored(message :String, color :Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), message]


func message_h4(message :String, color :Color, clear := true) -> void:
	if clear:
		_content.clear()
	_content.append_text("[font_size=16]%s[/font_size]" % _colored(message, color))


func message(message :String, color :Color) -> void:
	_content.clear()
	_content.append_text(_colored(message, color))


func _process(_delta):
	if _content != null and _content.is_visible_in_tree():
		_content.queue_redraw()


func show_update() -> void:
	# wait 20s to allow the editor to initialize itself
	await get_tree().create_timer(20).timeout
	message_h4("\n\n\nRequest release infos ... [img=24x24]%s[/img]" % spinner_icon, Color.SNOW)
	popup_centered_ratio(.5)
	if _debug_mode:
		var content :String = FileAccess.open("res://addons/gdUnit4/test/update/resources/markdown.txt", FileAccess.READ).get_as_text()
		var bbcode = await _md_reader.to_bbcode(content)
		message(bbcode, Color.DODGER_BLUE)
		_update_button.set_disabled(false)
		return
	var response :GdUnitUpdateClient.HttpResponse = await _update_client.request_releases()
	if response.code() == 200:
		var content :String = await extract_releases(response, _current_version)
		# finally force rescan to import images as textures
		if Engine.is_editor_hint():
			await rescan()
		message(content, Color.DODGER_BLUE)
		_update_button.set_disabled(false)
	else:
		message_h4("\n\n\nError checked request available releases!", Color.RED)


static func extract_latest_version(response :GdUnitUpdateClient.HttpResponse) -> GdUnit4Version:
	var body :Array = response.response()
	return GdUnit4Version.parse(body[0]["name"])


static func extract_zip_url(response :GdUnitUpdateClient.HttpResponse) -> String:
	var body :Array = response.response()
	return body[0]["zipball_url"]


func extract_releases(response :GdUnitUpdateClient.HttpResponse, current_version) -> String:
	await get_tree().process_frame
	var result :String = ""
	for release in response.response():
		if GdUnit4Version.parse(release["tag_name"]).equals(current_version):
			break
		var release_description :String = release["body"]
		var bbcode = await _md_reader.to_bbcode(release_description)
		result += bbcode
		result += "\n"
	return result


func rescan() -> void:
	await get_tree().process_frame
	if Engine.is_editor_hint():
		prints("Rescan Project")
		var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
		var fs := plugin.get_editor_interface().get_resource_filesystem()
		fs.scan()
		while fs.is_scanning():
			await get_tree().create_timer(.2).timeout


func _on_update_pressed():
	_update_button.set_disabled(true)
	message_h4("\nDownload Update ... [img=24x24]%s[/img]" % spinner_icon, Color.SNOW)
	var zip_file := GdUnitTools.temp_dir() + "/update.zip"
	var response :GdUnitUpdateClient.HttpResponse
	if _debug_mode:
		response = GdUnitUpdateClient.HttpResponse.new(200, PackedByteArray())
		zip_file = "res://update.zip"
	else:
		response = await _update_client.request_zip_package(_download_zip_url, zip_file)
	if response.code() != 200:
		push_warning("Update information cannot be retrieved from GitHub! \n Error code: %d : %s" % [response.code(), response.response()])
		await message("Update failed! Try it later again.", Color.RED)
		await get_tree().create_timer(3).timeout
		return
	run_update()


func run_update() -> void:
	# close all opend scripts before start the update
	if not _debug_mode:
		ScriptEditorControls.close_open_editor_scripts()
	# copy update source to a temp because the update is deleting the whole gdUnit folder
	DirAccess.make_dir_absolute("res://addons/.gdunit_update")
	DirAccess.copy_absolute("res://addons/gdUnit4/src/update/GdUnitUpdate.tscn", "res://addons/.gdunit_update/GdUnitUpdate.tscn")
	DirAccess.copy_absolute("res://addons/gdUnit4/src/update/GdUnitUpdate.gd", "res://addons/.gdunit_update/GdUnitUpdate.gd")
	var source := FileAccess.open("res://addons/gdUnit4/src/update/GdUnitUpdate.tscn", FileAccess.READ)
	var content := source.get_as_text().replace("res://addons/gdUnit4/src/update/GdUnitUpdate.gd", "res://addons/.gdunit_update/GdUnitUpdate.gd")
	var dest := FileAccess.open("res://addons/.gdunit_update/GdUnitUpdate.tscn", FileAccess.WRITE)
	dest.store_string(content)
	hide()
	if Engine.is_editor_hint():
		var update = load("res://addons/.gdunit_update/GdUnitUpdate.tscn").instantiate()
		get_parent().get_parent().add_child(update)
		update.popup_centered()


func _on_show_next_toggled(enabled :bool):
	GdUnitSettings.set_update_notification(enabled)


func _on_cancel_pressed():
	hide()


func _on_content_meta_clicked(meta :String):
	var properties = str_to_var(meta)
	if properties.has("url"):
		OS.shell_open(properties.get("url"))


func _on_content_meta_hover_started(meta :String):
	var properties = str_to_var(meta)
	if properties.has("tool_tip"):
		_content.set_tooltip_text(properties.get("tool_tip"))


func _on_content_meta_hover_ended(meta):
	_content.set_tooltip_text("")
