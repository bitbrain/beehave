@tool
extends RefCounted


const BeehaveUtils := preload("res://addons/beehave/utils/utils.gd")


const SUCCESS_COLOR := Color("#009944c8")
const NORMAL_COLOR := Color("#15181e")
const FAILURE_COLOR := Color("#cf000f80")
const RUNNING_COLOR := Color("#ffcc00c8")

var empty: StyleBoxEmpty
var normal: StyleBoxFlat
var success: StyleBoxFlat
var failure: StyleBoxFlat
var running: StyleBoxFlat


func _init() -> void:
	var plugin := BeehaveUtils.get_plugin()
	if not plugin:
		return

	var editor_scale := BeehaveUtils.get_editor_scale()

	empty = StyleBoxEmpty.new()

	normal = plugin.get_editor_interface().get_base_control().get_theme_stylebox(&"frame", &"GraphNode").duplicate()

	success = plugin.get_editor_interface().get_base_control().get_theme_stylebox(&"selected_frame", &"GraphNode").duplicate()
	failure = success.duplicate()
	running = success.duplicate()

	success.border_color = SUCCESS_COLOR
	failure.border_color = FAILURE_COLOR
	running.border_color = RUNNING_COLOR
