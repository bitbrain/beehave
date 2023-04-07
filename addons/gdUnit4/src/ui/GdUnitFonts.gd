class_name GdUnitFonts
extends RefCounted

const FONT_MONO             = "res://addons/gdUnit4/src/update/assets/fonts/static/RobotoMono-Regular.ttf"
const FONT_MONO_BOLT        = "res://addons/gdUnit4/src/update/assets/fonts/static/RobotoMono-Bold.ttf"
const FONT_MONO_BOLT_ITALIC = "res://addons/gdUnit4/src/update/assets/fonts/static/RobotoMono-BoldItalic.ttf"
const FONT_MONO_ITALIC      = "res://addons/gdUnit4/src/update/assets/fonts/static/RobotoMono-Italic.ttf"


static func init_fonts(item: CanvasItem) -> float:
	# add a default fallback font
	item.set("theme_override_fonts/font", create_font(FONT_MONO, 16))
	item.set("theme_override_fonts/normal_font", create_font(FONT_MONO, 16))
	item.set("theme_override_font_sizes/font_size", 16)
	if Engine.is_editor_hint():
		var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
		var settings := plugin.get_editor_interface().get_editor_settings()
		var scale_factor :=  plugin.get_editor_interface().get_editor_scale()
		var font_size = settings.get_setting("interface/editor/main_font_size")
		font_size *= scale_factor
		var font_mono := create_font(FONT_MONO, font_size)
		item.set("theme_override_fonts/normal_font", font_mono)
		item.set("theme_override_fonts/bold_font", create_font(FONT_MONO_BOLT, font_size))
		item.set("theme_override_fonts/italics_font", create_font(FONT_MONO_ITALIC, font_size))
		item.set("theme_override_fonts/bold_italics_font", create_font(FONT_MONO_BOLT_ITALIC, font_size))
		item.set("theme_override_fonts/mono_font", font_mono)
		item.set("theme_override_font_sizes/font_size", font_size)
		item.set("theme_override_font_sizes/normal_font_size", font_size)
		item.set("theme_override_font_sizes/bold_font_size", font_size)
		item.set("theme_override_font_sizes/italics_font_size", font_size)
		item.set("theme_override_font_sizes/bold_italics_font_size", font_size)
		item.set("theme_override_font_sizes/mono_font_size", font_size)
		return font_size
	return 16.0

static func create_font(font_resource: String, size: float) -> Font:
	var font := FontFile.new()
	font.font_data = load(font_resource)
	font.fixed_size = int(size)
	return font
