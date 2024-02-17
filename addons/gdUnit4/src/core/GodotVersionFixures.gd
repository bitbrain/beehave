## This service class contains helpers to wrap Godot functions and handle them carefully depending on the current Godot version
class_name GodotVersionFixures
extends RefCounted



## Returns the icon property defined by name and theme_type, if it exists.
static func get_icon(control :Control, icon_name :String) -> Texture2D:
	if Engine.get_version_info().hex >= 040200:
		return control.get_theme_icon(icon_name, "EditorIcons")
	return control.theme.get_icon(icon_name, "EditorIcons")


@warning_ignore("shadowed_global_identifier")
static func type_convert(value: Variant, type: int):
	return convert(value, type)


@warning_ignore("shadowed_global_identifier")
static func convert(value: Variant, type: int) -> Variant:
	return type_convert(value, type)
