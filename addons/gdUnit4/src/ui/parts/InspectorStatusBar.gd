@tool
extends PanelContainer

signal failure_next
signal failure_prevous

@onready var _errors = $GridContainer/Errors/value
@onready var _failures = $GridContainer/Failures/value
@onready var _button_failure_up := $GridContainer/Failures/buttons/failure_up
@onready var _button_failure_down := $GridContainer/Failures/buttons/failure_down

var total_failed := 0
var total_errors := 0

func _ready():
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	_failures.text = "0"
	_errors.text = "0"
	var editor :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var editior_control := editor.get_editor_interface().get_base_control()
	_button_failure_up.icon = GodotVersionFixures.get_icon(editior_control, "ArrowUp")
	_button_failure_down.icon = GodotVersionFixures.get_icon(editior_control, "ArrowDown")


func status_changed(errors :int, failed :int):
	total_failed += failed
	total_errors += errors
	_failures.text = str(total_failed)
	_errors.text = str(total_errors)


func _on_gdunit_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			total_failed = 0
			total_errors = 0
			status_changed(0, 0)
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())


func _on_failure_up_pressed():
	emit_signal("failure_prevous")


func _on_failure_down_pressed():
	emit_signal("failure_next")
