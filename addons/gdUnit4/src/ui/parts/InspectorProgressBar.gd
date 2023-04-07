@tool
extends ProgressBar

@onready var bar = $"."
@onready var status = $Label
@onready var style :StyleBoxFlat = bar.get("theme_override_styles/fill")


func _ready():
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	style.bg_color = Color.DARK_GREEN


func progress_init(p_max_value :int) -> void:
	bar.value = 0
	bar.max_value = p_max_value
	style.bg_color = Color.DARK_GREEN


func progress_update(p_value :int, failed :int, p_max_value :int = -1) -> void:
	bar.value += p_value
	if p_max_value != -1:
		bar.max_value = p_max_value
	status.text = str(bar.value) + ":" + str(bar.max_value)
	# if faild change color to red
	if failed > 0:
		style.bg_color = Color.DARK_RED


func _on_gdunit_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			progress_init(event.total_count())
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			progress_update(1, event.is_failed())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			progress_update(0, event.is_failed())
			pass
