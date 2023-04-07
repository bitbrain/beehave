@tool
extends PanelContainer

signal jump_to_orphan_nodes

@onready var ICON_GREEN = load("res://addons/gdUnit4/src/ui/assets/orphan/orphan_green.svg")
@onready var ICON_RED = load("res://addons/gdUnit4/src/ui/assets/orphan/orphan_animated_icon.tres")

@onready var _time = $GridContainer/Time/value
@onready var _orphans = $GridContainer/Orphan/value
@onready var _orphan_button := $GridContainer/Orphan/Button

var total_elapsed_time := 0
var total_orphans := 0

func _ready():
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	_time.text = ""
	_orphans.text = "0"


func status_changed(elapsed_time :int, orphan_nodes :int):
	total_elapsed_time += elapsed_time
	total_orphans += orphan_nodes
	_time.text = LocalTime.elapsed(total_elapsed_time)
	_orphans.text = str(total_orphans)
	if total_orphans > 0:
		_orphan_button.icon = ICON_RED


func _on_gdunit_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			_orphan_button.icon = ICON_GREEN
			total_elapsed_time = 0
			total_orphans = 0
			status_changed(0, 0)
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			status_changed(0, event.orphan_nodes())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			status_changed(event.elapsed_time(), event.orphan_nodes())


func _on_ToolButton_pressed():
	emit_signal("jump_to_orphan_nodes")
