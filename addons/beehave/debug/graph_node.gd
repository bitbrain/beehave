@tool
extends GraphNode


const BeehaveUtils := preload("res://addons/beehave/utils/utils.gd")


const DEFAULT_COLOR := Color("#dad4cb")

const PORT_TOP_ICON := preload("icons/port_top.svg")
const PORT_BOTTOM_ICON := preload("icons/port_bottom.svg")
const PORT_LEFT_ICON := preload("icons/port_left.svg")
const PORT_RIGHT_ICON := preload("icons/port_right.svg")


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

var layout_size: float:
	get:
		return size.y if horizontal else size.x


var panel: PanelContainer
var icon_rect: TextureRect
var title_label: Label
var container: VBoxContainer
var label: Label

var frames: RefCounted
var horizontal: bool = false


func _init(frames:RefCounted, horizontal: bool = false) -> void:
	self.frames = frames
	self.horizontal = horizontal


func _ready() -> void:
	custom_minimum_size = Vector2(50, 50) * BeehaveUtils.get_editor_scale()
	draggable = false

	add_theme_stylebox_override("frame", frames.empty if frames != null else null)
	add_theme_stylebox_override("selected_frame", frames.empty if frames != null else null)
	add_theme_color_override("close_color", Color.TRANSPARENT)
	add_theme_icon_override("close", ImageTexture.new())

	# For top port
	add_child(Control.new())

	panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", frames.normal if frames != null else null)
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


func set_slots(left_enabled: bool, right_enabled: bool) -> void:
	if horizontal:
		set_slot(1, left_enabled, 0, Color.WHITE, right_enabled, 0, Color.WHITE, PORT_LEFT_ICON, PORT_RIGHT_ICON)
	else:
		set_slot(0, left_enabled, 0, Color.WHITE, false, -2, Color.TRANSPARENT, PORT_TOP_ICON, null)
		set_slot(2, false, -1, Color.TRANSPARENT, right_enabled, 0, Color.WHITE, null, PORT_BOTTOM_ICON)


func set_color(color: Color) -> void:
	set_input_color(color)
	set_output_color(color)


func set_input_color(color: Color) -> void:
	set_slot_color_left(1 if horizontal else 0, color)


func set_output_color(color: Color) -> void:
	set_slot_color_right(1 if horizontal else 2, color)


func _on_size_changed():
	add_theme_constant_override("port_offset", 12 * BeehaveUtils.get_editor_scale() if horizontal else round(size.x / 2.0))
