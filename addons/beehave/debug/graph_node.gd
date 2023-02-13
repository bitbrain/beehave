@tool
extends GraphNode

const DEFAULT_COLOR := Color("#dad4cb")

const PORT_TOP_ICON := preload("../icons/port_top.svg")
const PORT_BOTTOM_ICON := preload("../icons/port_bottom.svg")


@export var title_text: String:
	set(value):
		title_text = value
		if title_label:
			title_label.text = value

@export var text: String:
	set(value):
		text = value
		if label:
			label.text = " " if text.is_empty() else text

@export var icon: Texture2D:
	set(value):
		icon = value
		if icon_rect:
			icon_rect.texture = value

var panel: PanelContainer
var icon_rect: TextureRect
var title_label: Label
var container: VBoxContainer
var label: Label

var frames: RefCounted = BeehaveUtils.get_frames()


func _ready() -> void:
	custom_minimum_size = Vector2(150, 100) * BeehaveUtils.get_editor_scale()
	draggable = false

	add_theme_stylebox_override("frame", frames.empty)
	add_theme_stylebox_override("selected_frame", frames.empty)
	add_theme_color_override("close_color", Color.TRANSPARENT)
	add_theme_icon_override("close", ImageTexture.new())

	# For top port
	add_child(Control.new())

	panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", frames.normal)
	add_child(panel)

	var vbox_container := VBoxContainer.new()
	panel.add_child(vbox_container)

	var title_size := 24 * BeehaveUtils.get_editor_scale()
	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_top", -title_size - 2 * BeehaveUtils.get_editor_scale())
	margin_container.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_container.add_child(margin_container)

	var title_container := HBoxContainer.new()
	title_container.add_child(Control.new())
	title_container.mouse_filter = Control.MOUSE_FILTER_PASS
	title_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_container.add_child(title_container)

	icon_rect = TextureRect.new()
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_container.add_child(icon_rect)

	title_label = Label.new()
	title_label.add_theme_color_override("font_color", DEFAULT_COLOR)
	title_label.add_theme_font_override("font", get_theme_font("title_font"))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = title_text
	title_container.add_child(title_label)

	title_container.add_child(Control.new())

	container = VBoxContainer.new()
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(container)

	label = Label.new()
	label.text = " " if text.is_empty() else text
	container.add_child(label)

	# For bottom port
	add_child(Control.new())

	minimum_size_changed.connect(_on_size_changed)
	_on_size_changed.call_deferred()


func set_status(status: int) -> void:
	panel.add_theme_stylebox_override("panel", _get_stylebox(status))


func _get_stylebox(status: int) -> StyleBox:
	match status:
		0: return frames.success
		1: return frames.failure
		2: return frames.running
		_: return frames.normal


func set_input(enabled: bool, type: int, color: Color) -> void:
	set_slot(0, enabled, type, color, false, -1, Color.TRANSPARENT, PORT_TOP_ICON, null)


func set_output(enabled: bool, type: int, color: Color) -> void:
	set_slot(2, false, -2, Color.TRANSPARENT, enabled, type, color, null, PORT_BOTTOM_ICON)


func set_color(color: Color) -> void:
	set_input_color(color)
	set_output_color(color)


func set_input_color(color: Color) -> void:
	set_slot(0, is_slot_enabled_left(0), get_slot_type_left(0), color, false, -1, Color.TRANSPARENT, PORT_TOP_ICON, null)


func set_output_color(color: Color) -> void:
	set_slot(2, false, -2, Color.TRANSPARENT, is_slot_enabled_right(2), get_slot_type_right(2), color, null, PORT_BOTTOM_ICON)


func _on_size_changed():
	add_theme_constant_override("port_offset", round(size.x / 2.0))
