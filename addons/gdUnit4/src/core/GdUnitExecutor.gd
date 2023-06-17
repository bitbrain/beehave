extends Node

signal ExecutionCompleted()


const INIT = 0
const STAGE_TEST_SUITE_BEFORE = GdUnitReportCollector.STAGE_TEST_SUITE_BEFORE
const STAGE_TEST_SUITE_AFTER = GdUnitReportCollector.STAGE_TEST_SUITE_AFTER
const STAGE_TEST_CASE_BEFORE = GdUnitReportCollector.STAGE_TEST_CASE_BEFORE
const STAGE_TEST_CASE_EXECUTE = GdUnitReportCollector.STAGE_TEST_CASE_EXECUTE
const STAGE_TEST_CASE_AFTER = GdUnitReportCollector.STAGE_TEST_CASE_AFTER

var _testsuite_timer :LocalTime
var _testcase_timer :LocalTime

var _memory_pool :GdUnitMemoryPool = GdUnitMemoryPool.new()
var _report_errors_enabled :bool
var _report_collector : = GdUnitReportCollector.new()


var _total_test_execution_orphans :int
var _total_test_warnings :int
var _total_test_failed :int
var _total_test_errors :int
var _fail_fast := false
var _debug := false


func _init(debug := false):
	set_name("GdUnitExecutor%s" % ("Debug" if debug else ""))
	_debug = debug


func _ready():
	_report_errors_enabled = GdUnitSettings.is_report_push_errors()


func fail_fast(enabled :bool) -> void:
	_fail_fast = enabled


func set_stage(stage :int) -> void:
	_report_collector.set_stage(stage)


func set_consume_reports(enabled :bool) -> void:
	_report_collector.set_consume_reports(enabled)


func fire_event(event :GdUnitEvent) -> void:
	if _debug:
		GdUnitSignals.instance().gdunit_event_debug.emit(event)
	else:
		GdUnitSignals.instance().gdunit_event.emit(event)


func fire_test_skipped(test_suite :GdUnitTestSuite, test_case :_TestCase):
	fire_event(GdUnitEvent.new()\
		.test_before(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name()))
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
		.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, [report]))


func suite_before(test_suite :GdUnitTestSuite, total_count :int):
	set_stage(STAGE_TEST_SUITE_BEFORE)
	fire_event(GdUnitEvent.new()\
		.suite_before(test_suite.get_script().resource_path, test_suite.get_name(), total_count))
	_testsuite_timer = LocalTime.now()
	_total_test_errors = 0
	_total_test_failed = 0
	_total_test_warnings = 0
	if not test_suite.is_skipped():
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.TESTSUITE, true)
		@warning_ignore("redundant_await")
		await test_suite.before()
		_memory_pool.monitor_stop()


func suite_after(test_suite :GdUnitTestSuite):
	set_stage(STAGE_TEST_SUITE_AFTER)
	GdUnitTools.clear_tmp()
	
	var is_warning := _total_test_warnings != 0
	var is_skipped := test_suite.is_skipped()
	var skip_count := test_suite.get_child_count()
	var orphan_nodes := 0
	var reports := _report_collector.get_reports(STAGE_TEST_SUITE_BEFORE)
	
	if not is_skipped:
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.TESTSUITE)
		skip_count = 0
		@warning_ignore("redundant_await")
		await test_suite.after()
		GdUnitTools.append_array(reports, _report_collector.get_reports(STAGE_TEST_SUITE_AFTER))
		_memory_pool.free_pool()
		_memory_pool.monitor_stop()
		orphan_nodes = _memory_pool.orphan_nodes()
		if orphan_nodes > 0:
			reports.push_front(GdUnitReport.new() \
				.create(GdUnitReport.WARN, 1, GdAssertMessages.orphan_detected_on_suite_setup(orphan_nodes)))
	
	var is_error := _total_test_errors != 0 or _report_collector.has_errors(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)
	var is_failed := _total_test_failed != 0 or _report_collector.has_failures(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)
	# create report
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: orphan_nodes,
		GdUnitEvent.ELAPSED_TIME: _testsuite_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: is_warning,
		GdUnitEvent.ERRORS: is_error,
		GdUnitEvent.ERROR_COUNT: _report_collector.count_errors(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER),
		GdUnitEvent.FAILED: is_failed,
		GdUnitEvent.FAILED_COUNT: _report_collector.count_failures(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER),
		GdUnitEvent.SKIPPED_COUNT: skip_count,
		GdUnitEvent.SKIPPED: is_skipped
	}
	fire_event(GdUnitEvent.new().suite_after(test_suite.get_script().resource_path, test_suite.get_name(), statistics, reports))
	_report_collector.clear_reports(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)


func test_before(test_suite :GdUnitTestSuite, test_case_name :String, do_fire_event := true):
	set_stage(STAGE_TEST_CASE_BEFORE)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.TESTCASE, true)
	
	_total_test_execution_orphans = 0
	if do_fire_event:
		_testcase_timer = LocalTime.now()
		fire_event(GdUnitEvent.new()\
			.test_before(test_suite.get_script().resource_path, test_suite.get_name(), test_case_name))
	
	@warning_ignore("redundant_await")
	await test_suite.before_test()
	_memory_pool.monitor_stop()


func test_after(test_suite :GdUnitTestSuite, test_case :_TestCase, test_case_name :String, do_fire_event := true):
	_memory_pool.free_pool()
	# give objects time to finallize
	await get_tree().process_frame
	_memory_pool.monitor_stop()
	var execution_orphan_nodes = _memory_pool.orphan_nodes()
	if execution_orphan_nodes > 0:
		_total_test_execution_orphans += execution_orphan_nodes
		_total_test_warnings += 1
		_report_collector.push_front(STAGE_TEST_CASE_EXECUTE, GdUnitReport.new() \
			.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_test(execution_orphan_nodes)))
	
	var is_error := false
	if test_case.is_interupted() and not test_case.is_expect_interupted():
		_report_collector.add_report(STAGE_TEST_CASE_EXECUTE, test_case.report())
		is_error = true
	
	set_stage(STAGE_TEST_CASE_AFTER)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.TESTCASE)
	@warning_ignore("redundant_await")
	await test_suite.after_test()
	_memory_pool.free_pool()
	_memory_pool.monitor_stop()
	var test_setup_orphan_nodes = _memory_pool.orphan_nodes()
	if test_setup_orphan_nodes > 0:
		_total_test_warnings += 1
		_total_test_execution_orphans += test_setup_orphan_nodes
		_report_collector.push_front(STAGE_TEST_CASE_AFTER, GdUnitReport.new() \
			.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_test_setup(test_setup_orphan_nodes)))
	
	var reports := _report_collector.get_reports(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	var error_count := _report_collector.count_errors(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER) if is_error else 0
	var failure_count := _report_collector.count_failures(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	var is_warning := _report_collector.has_warnings(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	
	_total_test_errors += error_count
	_total_test_failed += failure_count
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: _total_test_execution_orphans,
		GdUnitEvent.ELAPSED_TIME: _testcase_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: is_warning,
		GdUnitEvent.ERRORS: is_error,
		GdUnitEvent.ERROR_COUNT: error_count,
		GdUnitEvent.FAILED: failure_count > 0,
		GdUnitEvent.FAILED_COUNT: failure_count,
		GdUnitEvent.SKIPPED: test_case.is_skipped(),
		GdUnitEvent.SKIPPED_COUNT: int(test_case.is_skipped()),
	}
	
	if do_fire_event:
		fire_event(GdUnitEvent.new()\
			.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case_name, statistics, reports.duplicate()))
	_report_collector.clear_reports(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)


func execute_test_case_single(test_suite :GdUnitTestSuite, test_case :_TestCase):
	await test_before(test_suite, test_case.get_name())
	
	set_stage(STAGE_TEST_CASE_EXECUTE)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.EXECUTE, true)
	test_case.generate_seed()
	await test_case.execute()
	test_case.dispose()
	await test_after(test_suite, test_case, test_case.get_name())


func execute_test_case_iterative(test_suite :GdUnitTestSuite, test_case :_TestCase):
	test_case.generate_seed()
	var fuzzers := create_fuzzers(test_suite, test_case)
	var is_failure := false
	for iteration in test_case.iterations():
		# call before_test for each iteration
		await test_before(test_suite, test_case.get_name(), iteration==0)
		
		set_stage(STAGE_TEST_CASE_EXECUTE)
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.EXECUTE, true)
		await test_case.execute(fuzzers, iteration)
		
		var reports := _report_collector.get_reports(STAGE_TEST_CASE_EXECUTE)
		# interrupt at first failure
		if not reports.is_empty():
			is_failure = true
			var report :GdUnitReport = _report_collector.pop_front(STAGE_TEST_CASE_EXECUTE)
			_report_collector.add_report(STAGE_TEST_CASE_EXECUTE, GdUnitReport.new() \
					.create(GdUnitReport.FAILURE, report.line_number(), GdAssertMessages.fuzzer_interuped(iteration, report.message())))
		
		if test_case.is_interupted():
			is_failure = true
		
		# call after_test for each iteration
		await test_after(test_suite, test_case, test_case.get_name(), iteration==test_case.iterations()-1 or is_failure)
		
		if test_case.is_interupted() or is_failure:
			break
	test_case.dispose()


func execute_test_case_parameterized(test_suite :GdUnitTestSuite, test_case :_TestCase):
	var testcase_timer = LocalTime.now()
	fire_event(GdUnitEvent.new()\
		.test_before(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name()))
	
	var current_error_count = _total_test_errors
	var current_failed_count = _total_test_failed
	var current_warning_count =_total_test_warnings
	var test_case_parameters := test_case.test_parameters()
	var test_parameter_index := test_case.test_parameter_index()
	var test_case_names := test_case.test_case_names()
	for test_case_index in test_case.test_parameters().size():
		# is test_parameter_index is set, we run this parameterized test only
		if test_parameter_index != -1 and test_parameter_index != test_case_index:
			continue
		await test_before(test_suite, test_case_names[test_case_index])
		set_stage(STAGE_TEST_CASE_EXECUTE)
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.POOL.EXECUTE, true)
		await test_case.execute(test_case_parameters[test_case_index])
		await test_after(test_suite, test_case, test_case_names[test_case_index])
		if test_case.is_interupted():
			break
	test_case.dispose()
	
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: _total_test_execution_orphans,
		GdUnitEvent.ELAPSED_TIME: testcase_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: current_warning_count != _total_test_warnings,
		GdUnitEvent.ERRORS: current_error_count != _total_test_errors,
		GdUnitEvent.ERROR_COUNT: 0,
		GdUnitEvent.FAILED: current_failed_count != _total_test_failed,
		GdUnitEvent.FAILED_COUNT: 0,
		GdUnitEvent.SKIPPED: test_case.is_skipped(),
		GdUnitEvent.SKIPPED_COUNT: int(test_case.is_skipped()),
	}
	fire_event(GdUnitEvent.new()\
		.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, []))


func execute(test_suite :GdUnitTestSuite):
	await Execute(test_suite)


func Execute(test_suite :GdUnitTestSuite) -> void:
	var context := GdUnitThreadManager.get_current_context()
	context.init()
	# stop checked first error if fail fast enabled
	if _fail_fast and _total_test_failed > 0:
		test_suite.free()
		await get_tree().process_frame
		ExecutionCompleted.emit()
		return
	var ts := test_suite
	await suite_before(ts, ts.get_child_count())
	
	if not ts.is_skipped():
		# needs at least one yielding otherwise the waiting function is blocked
		if ts.get_child_count() == 0:
			await get_tree().process_frame
		
		for test_case_index in ts.get_child_count():
			var test_case := ts.get_child(test_case_index) as _TestCase
			# only iterate over test case, we need to filter because of possible adding other child types checked before() or before_test()
			if not test_case is _TestCase:
				continue
			# stop checked first error if fail fast enabled
			if _fail_fast and _total_test_failed > 0:
				break
			ts.set_active_test_case(test_case.get_name())
			if test_case.is_skipped():
				fire_test_skipped(ts, test_case)
				await get_tree().process_frame
			else:
				if test_case.is_parameterized():
					await execute_test_case_parameterized(ts, test_case)
				elif test_case.has_fuzzer():
					await execute_test_case_iterative(ts, test_case)
				else:
					await execute_test_case_single(ts, test_case)
			if test_case.is_interupted():
				# it needs to go this hard way to kill the outstanding yields of a test case when the test timed out
				# we delete the current test suite where is execute the current test case to kill the function state
				# and replace it by a clone without function state
				ts = await clone_test_suite(ts)
				
	await suite_after(ts)
	ts.free()
	context.clear()
	ExecutionCompleted.emit()


func copy_properties(source :Object, target :Object):
	if not source is _TestCase and not source is GdUnitTestSuite:
		return
	for property in source.get_property_list():
		var property_name = property["name"]
		target.set(property_name, source.get(property_name))


# clones a test suite and moves the test cases to new instance
func clone_test_suite(test_suite :GdUnitTestSuite) -> GdUnitTestSuite:
	dispose_timers(test_suite)
	var parent := test_suite.get_parent()
	var _test_suite = test_suite.duplicate()
	copy_properties(test_suite, _test_suite)
	for child in test_suite.get_children():
		copy_properties(child, _test_suite.find_child(child.get_name(), true, false))
	# finally free current test suite instance
	parent.remove_child(test_suite)
	await get_tree().process_frame
	test_suite.free()
	parent.add_child(_test_suite)
	return _test_suite


func dispose_timers(test_suite :GdUnitTestSuite):
	GdUnitTools.release_timers()
	for child in test_suite.get_children():
		if child is Timer:
			child.stop()
			test_suite.remove_child(child)
			child.free()


func create_fuzzers(test_suite :GdUnitTestSuite, test_case :_TestCase) -> Array[Fuzzer]:
	if not test_case.has_fuzzer():
		return Array()
	var fuzzers :Array[Fuzzer] = []
	for fuzzer_arg in test_case.fuzzer_arguments():
		var fuzzer := FuzzerTool.create_fuzzer(test_suite.get_script(), fuzzer_arg)
		fuzzer._iteration_index = 0
		fuzzer._iteration_limit = test_case.iterations()
		fuzzers.append(fuzzer)
	return fuzzers
