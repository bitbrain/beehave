class_name GdUnitHtmlReport
extends GdUnitReportSummary

const REPORT_DIR_PREFIX = "report_"

var _report_path :String
var _iteration :int


func _init(path_ :String):
	_iteration = GdUnitFileAccess.find_last_path_index(path_, REPORT_DIR_PREFIX) + 1
	_report_path = "%s/%s%d" % [path_, REPORT_DIR_PREFIX, _iteration]
	DirAccess.make_dir_recursive_absolute(_report_path)


func add_testsuite_report(suite_report :GdUnitTestSuiteReport):
	_reports.append(suite_report)


func add_testcase_report(resource_path_ :String, suite_report :GdUnitTestCaseReport) -> void:
	for report in _reports:
		if report.resource_path() == resource_path_:
			report.add_report(suite_report)


func update_test_suite_report(
	resource_path_ :String,
	duration_ :int,
	_is_error :bool,
	is_failed_: bool,
	_is_warning :bool,
	is_skipped_ :bool,
	skipped_count_ :int,
	failed_count_ :int,
	orphan_count_ :int,
	reports_ :Array = []) -> void:
	
	for report in _reports:
		if report.resource_path() == resource_path_:
			report.set_duration(duration_)
			report.set_failed(is_failed_, failed_count_)
			report.set_orphans(orphan_count_)
			report.set_reports(reports_)
	if is_skipped_:
		_skipped_count = skipped_count_


func update_testcase_report(resource_path_ :String, test_report :GdUnitTestCaseReport):
	for report in _reports:
		if report.resource_path() == resource_path_:
			report.update(test_report)


func write() -> String:
	var template := GdUnitHtmlPatterns.load_template("res://addons/gdUnit4/src/report/template/index.html")
	var to_write = GdUnitHtmlPatterns.build(template, self, "")
	to_write = apply_path_reports(_report_path, to_write, _reports)
	to_write = apply_testsuite_reports(_report_path, to_write, _reports)
	# write report
	var index_file := "%s/index.html" % _report_path
	FileAccess.open(index_file, FileAccess.WRITE).store_string(to_write)
	GdUnitFileAccess.copy_directory("res://addons/gdUnit4/src/report/template/css/", _report_path + "/css")
	return index_file


func delete_history(max_reports :int) -> int:
	return GdUnitFileAccess.delete_path_index_lower_equals_than(_report_path.get_base_dir(), REPORT_DIR_PREFIX, _iteration-max_reports)


func apply_path_reports(report_dir :String, template :String, reports_ :Array) -> String:
	var path_report_mapping := GdUnitByPathReport.sort_reports_by_path(reports_)
	var table_records := PackedStringArray()
	var paths := path_report_mapping.keys()
	paths.sort()
	for path_ in paths:
		var report := GdUnitByPathReport.new(path_, path_report_mapping.get(path_))
		var report_link :String = report.write(report_dir).replace(report_dir, ".")
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_PATHS, "\n".join(table_records))


func apply_testsuite_reports(report_dir :String, template :String, reports_ :Array) -> String:
	var table_records := PackedStringArray()
	for report in reports_:
		var report_link :String = report.write(report_dir).replace(report_dir, ".")
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_TESTSUITES, "\n".join(table_records))


func iteration() -> int:
	return _iteration
