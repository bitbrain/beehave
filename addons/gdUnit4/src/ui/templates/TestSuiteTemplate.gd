@tool
extends MarginContainer

@onready var _template_editor :CodeEdit = $VBoxContainer/EdiorLayout/Editor
@onready var _tags_editor :CodeEdit = $Tags/MarginContainer/TextEdit
@onready var _title_bar :Panel = $VBoxContainer/sub_category
@onready var _save_button :Button = $VBoxContainer/Panel/HBoxContainer/Save
@onready var _selected_type :OptionButton = $VBoxContainer/EdiorLayout/Editor/MarginContainer/HBoxContainer/SelectType
@onready var _show_tags  :PopupPanel = $Tags


var gd_key_words :PackedStringArray = ["extends", "class_name", "const", "var", "onready", "func", "void", "pass"]
var gdunit_key_words :PackedStringArray = ["GdUnitTestSuite", "before", "after", "before_test", "after_test"]
var _selected_template :int


func _ready() -> void:
	setup_editor_colors()
	setup_fonts()
	setup_supported_types()
	load_template(GdUnitTestSuiteTemplate.TEMPLATE_ID_GD)
	setup_tags_help()


func _notification(what :int) -> void:
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		setup_fonts()


func setup_editor_colors() -> void:
	if not Engine.is_editor_hint():
		return
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var settings := plugin.get_editor_interface().get_editor_settings()
	var background_color :Color = settings.get_setting("text_editor/theme/highlighting/background_color")
	var text_color :Color = settings.get_setting("text_editor/theme/highlighting/text_color")
	var selection_color :Color = settings.get_setting("text_editor/theme/highlighting/selection_color")
	
	for e in [_template_editor, _tags_editor]:
		var editor :CodeEdit = e
		editor.add_theme_color_override("background_color", background_color)
		editor.add_theme_color_override("font_color", text_color)
		editor.add_theme_color_override("font_readonly_color", text_color)
		editor.add_theme_color_override("font_selected_color", selection_color)
		setup_highlighter(editor, settings)


func setup_highlighter(editor :CodeEdit, settings :EditorSettings) -> void:
	var highlighter := CodeHighlighter.new()
	editor.set_syntax_highlighter(highlighter)
	var number_color :Color = settings.get_setting("text_editor/theme/highlighting/number_color")
	var symbol_color :Color = settings.get_setting("text_editor/theme/highlighting/symbol_color")
	var function_color :Color = settings.get_setting("text_editor/theme/highlighting/function_color")
	var member_variable_color :Color = settings.get_setting("text_editor/theme/highlighting/member_variable_color")
	var comment_color :Color = settings.get_setting("text_editor/theme/highlighting/comment_color")
	var keyword_color :Color = settings.get_setting("text_editor/theme/highlighting/keyword_color")
	var base_type_color :Color = settings.get_setting("text_editor/theme/highlighting/base_type_color")
	var annotation_color :Color = settings.get_setting("text_editor/theme/highlighting/gdscript/annotation_color")
	
	highlighter.clear_color_regions()
	highlighter.clear_keyword_colors()
	highlighter.add_color_region("#", "", comment_color, true)
	highlighter.add_color_region("${", "}", Color.YELLOW)
	highlighter.add_color_region("'", "'", Color.YELLOW)
	highlighter.add_color_region("\"", "\"", Color.YELLOW)
	highlighter.number_color = number_color
	highlighter.symbol_color = symbol_color
	highlighter.function_color = function_color
	highlighter.member_variable_color = member_variable_color
	highlighter.add_keyword_color("@", annotation_color)
	highlighter.add_keyword_color("warning_ignore", annotation_color)
	for word in gd_key_words:
		highlighter.add_keyword_color(word, keyword_color)
	for word in gdunit_key_words:
		highlighter.add_keyword_color(word, base_type_color)


func setup_fonts() -> void:
	if _template_editor:
		GdUnitFonts.init_fonts(_template_editor)
		var font_size := GdUnitFonts.init_fonts(_tags_editor)
		_title_bar.size.y = font_size + 16
		_title_bar.custom_minimum_size.y = font_size + 16


func setup_supported_types() -> void:
	_selected_type.clear()
	_selected_type.add_item("GD - GDScript", GdUnitTestSuiteTemplate.TEMPLATE_ID_GD)
	_selected_type.add_item("C# - CSharpScript", GdUnitTestSuiteTemplate.TEMPLATE_ID_CS)


func setup_tags_help() -> void:
	_tags_editor.set_text(GdUnitTestSuiteTemplate.load_tags(_selected_template))


func load_template(template_id :int) -> void:
	_selected_template = template_id
	_template_editor.set_text(GdUnitTestSuiteTemplate.load_template(template_id))


func _on_Restore_pressed() -> void:
	_template_editor.set_text(GdUnitTestSuiteTemplate.default_template(_selected_template))
	GdUnitTestSuiteTemplate.reset_to_default(_selected_template)
	_save_button.disabled = true


func _on_Save_pressed() -> void:
	GdUnitTestSuiteTemplate.save_template(_selected_template, _template_editor.get_text())
	_save_button.disabled = true


func _on_Tags_pressed() -> void:
	_show_tags.popup_centered_ratio(.5)


func _on_Editor_text_changed() -> void:
	_save_button.disabled = false


func _on_SelectType_item_selected(index :int) -> void:
	load_template(_selected_type.get_item_id(index))
	setup_tags_help()
