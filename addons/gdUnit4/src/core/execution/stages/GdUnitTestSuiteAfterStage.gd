## The test suite shutdown hook implementation.[br]
## It executes the 'after()' block from the test-suite.
class_name GdUnitTestSuiteAfterStage
extends IGdUnitExecutionStage


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")


func _execute(context :GdUnitExecutionContext) -> void:
	var test_suite := context.test_suite
	
	@warning_ignore("redundant_await")
	await test_suite.after()
	# unreference last used assert form the test to prevent memory leaks
	GdUnitThreadManager.get_current_context().set_assert(null)
	await context.gc()
	
	var reports := context.reports()
	var orphans := context.count_orphans()
	if orphans > 0:
		reports.push_front(GdUnitReport.new() \
			.create(GdUnitReport.WARN, 1, GdAssertMessages.orphan_detected_on_suite_setup(orphans)))
	fire_event(GdUnitEvent.new().suite_after(test_suite.get_script().resource_path, test_suite.get_name(), context.build_report_statistics(orphans, false), reports))
	
	GdUnitFileAccess.clear_tmp()
	# Guard that checks if all doubled (spy/mock) objects are released
	GdUnitClassDoubler.check_leaked_instances()
