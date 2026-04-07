## The test case shutdown hook implementation.[br]
## It executes the 'test_after()' block from the test-suite.
class_name GdUnitTestCaseAfterStage
extends IGdUnitExecutionStage


var _test_name :StringName = ""
var _call_stage :bool


func _init(call_stage := true):
	_call_stage = call_stage


func _execute(context :GdUnitExecutionContext) -> void:
	var test_suite := context.test_suite
	if _call_stage:
		@warning_ignore("redundant_await")
		await test_suite.after_test()
	# unreference last used assert form the test to prevent memory leaks
	GdUnitThreadManager.get_current_context().set_assert(null)
	await context.gc()
	await context.error_monitor_stop()
	if context.test_case.is_skipped():
		fire_test_skipped(context)
	else:
		fire_test_ended(context)
	if is_instance_valid(context.test_case):
		context.test_case.dispose()


func set_test_name(test_name :StringName):
	_test_name = test_name


func fire_test_ended(context :GdUnitExecutionContext) -> void:
	var test_suite := context.test_suite
	var test_name := context._test_case_name if _test_name.is_empty() else _test_name
	var reports := collect_reports(context)
	var orphans := collect_orphans(context, reports)
	
	fire_event(GdUnitEvent.new()\
		.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_name, context.build_report_statistics(orphans), reports))


func collect_orphans(context :GdUnitExecutionContext, reports :Array[GdUnitReport]) -> int:
	var orphans := 0
	if not context._sub_context.is_empty():
		orphans += add_orphan_report_test(context._sub_context[0], reports)
	orphans += add_orphan_report_teststage(context, reports)
	return orphans


func collect_reports(context :GdUnitExecutionContext) -> Array[GdUnitReport]:
	var reports := context.reports()
	var test_case := context.test_case
	if test_case.is_interupted() and not test_case.is_expect_interupted():
		reports.push_back(test_case.report())
	# we combine the reports of test_before(), test_after() and test() to be reported by `fire_test_ended`
	if not context._sub_context.is_empty():
		reports.append_array(context._sub_context[0].reports())
		# needs finally to clean the test reports to avoid counting twice
		context._sub_context[0].reports().clear()
	return reports


func add_orphan_report_test(context :GdUnitExecutionContext, reports :Array[GdUnitReport]) -> int:
	var orphans := context.count_orphans()
	if orphans > 0:
		reports.push_front(GdUnitReport.new()\
			.create(GdUnitReport.WARN, context.test_case.line_number(), GdAssertMessages.orphan_detected_on_test(orphans)))
	return orphans


func add_orphan_report_teststage(context :GdUnitExecutionContext, reports :Array[GdUnitReport]) -> int:
	var orphans := context.count_orphans()
	if orphans > 0:
		reports.push_front(GdUnitReport.new()\
			.create(GdUnitReport.WARN, context.test_case.line_number(), GdAssertMessages.orphan_detected_on_test_setup(orphans)))
	return orphans


func fire_test_skipped(context :GdUnitExecutionContext):
	var test_suite := context.test_suite
	var test_case := context.test_case
	var test_case_name :=  context._test_case_name if _test_name.is_empty() else _test_name
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: 0,
		GdUnitEvent.ELAPSED_TIME: 0,
		GdUnitEvent.WARNINGS: false,
		GdUnitEvent.ERRORS: false,
		GdUnitEvent.ERROR_COUNT: 0,
		GdUnitEvent.FAILED: false,
		GdUnitEvent.FAILED_COUNT: 0,
		GdUnitEvent.SKIPPED: true,
		GdUnitEvent.SKIPPED_COUNT: 1,
	}
	var report := GdUnitReport.new().create(GdUnitReport.SKIPPED, test_case.line_number(), GdAssertMessages.test_skipped(test_case.skip_info()))
	fire_event(GdUnitEvent.new()\
		.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case_name, statistics, [report]))
