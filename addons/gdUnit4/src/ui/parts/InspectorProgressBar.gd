@tool
extends ProgressBar

@onready var bar = $"."
@onready var status = $Label
@onready var style :StyleBoxFlat = bar.get("theme_override_styles/fill")


func _ready():
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	style.bg_color = Color.DARK_GREEN
	update_text()


func progress_init(p_max_value :int) -> void:
	bar.value = 0
	bar.max_value = p_max_value
	style.bg_color = Color.DARK_GREEN
	update_text()


func progress_update(p_value :int, is_failed :bool) -> void:
	bar.value += p_value
	update_text()
	if is_failed:
		style.bg_color = Color.DARK_RED


func update_text() -> void:
	status.text = "%d:%d" % [bar.value, bar.max_value]


func _on_gdunit_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			progress_init(event.total_count())
		
		GdUnitEvent.TESTCASE_AFTER:
			# we only count when the test is finished (excluding parameterized test iterrations)
			# test_name:<number> indicates a parameterized test run
			if event.test_name().find(":") == -1:
				progress_update(1, event.is_failed() or event.is_error())
		
		GdUnitEvent.TESTSUITE_AFTER:
			progress_update(0, event.is_failed() or event.is_error())
