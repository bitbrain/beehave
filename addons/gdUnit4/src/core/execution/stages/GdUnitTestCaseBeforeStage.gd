## The test case startup hook implementation.[br]
## It executes the 'test_before()' block from the test-suite.
class_name GdUnitTestCaseBeforeStage
extends IGdUnitExecutionStage


var _test_name :StringName = ""
var _call_stage :bool


func _init(call_stage := true):
	_call_stage = call_stage


func _execute(context :GdUnitExecutionContext) -> void:
	var test_suite := context.test_suite
	var test_case_name := context._test_case_name if _test_name.is_empty() else _test_name
	
	fire_event(GdUnitEvent.new()\
		.test_before(test_suite.get_script().resource_path, test_suite.get_name(), test_case_name))
	
	if _call_stage:
		@warning_ignore("redundant_await")
		await test_suite.before_test()
	context.error_monitor_start()


func set_test_name(test_name :StringName):
	_test_name = test_name
