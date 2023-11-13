## The executor to run a test-suite
class_name GdUnitTestSuiteExecutor


# preload all asserts here
@warning_ignore("unused_private_class_variable")
var _assertions := GdUnitAssertions.new()
var _executeStage :IGdUnitExecutionStage = GdUnitTestSuiteExecutionStage.new()


func _init(debug_mode :bool = false):
	_executeStage.set_debug_mode(debug_mode)


func execute(test_suite :GdUnitTestSuite) -> void:
	var orphan_detection_enabled = GdUnitSettings.is_verbose_orphans()
	if not orphan_detection_enabled:
		prints("!!! Reporting orphan nodes is disabled. Please check GdUnit settings.")
	
	Engine.get_main_loop().root.call_deferred("add_child", test_suite)
	await Engine.get_main_loop().process_frame
	await _executeStage.execute(GdUnitExecutionContext.of_test_suite(test_suite))


func fail_fast(enabled :bool) -> void:
	_executeStage.fail_fast(enabled)
