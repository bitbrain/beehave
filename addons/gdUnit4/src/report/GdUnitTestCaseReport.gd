class_name GdUnitTestCaseReport
extends GdUnitReportSummary

var _suite_name :String
var _failure_reports :Array

func _init(
		p_resource_path :String,
		p_suite_name :String,
		test_name :String,
		is_error := false,
		_is_failed := false,
		failed_count :int = 0,
		orphan_count_ :int = 0,
		is_skipped := false,
		failure_reports :Array = [],
		p_duration :int = 0):
	_resource_path = p_resource_path
	_suite_name = p_suite_name
	_name = test_name
	_test_count = 1
	_error_count = is_error
	_failure_count = failed_count
	_orphan_count = orphan_count_
	_skipped_count = is_skipped
	_failure_reports = failure_reports
	_duration = p_duration


func suite_name() -> String:
	return _suite_name


func failure_report() -> String:
	var html_report := ""
	for r in _failure_reports:
		var report: GdUnitReport = r
		html_report += convert_rtf_to_html(report._to_string())
	return html_report


func create_record(_report_dir :String) -> String:
	return GdUnitHtmlPatterns.TABLE_RECORD_TESTCASE\
		.replace(GdUnitHtmlPatterns.REPORT_STATE, report_state())\
		.replace(GdUnitHtmlPatterns.TESTCASE_NAME, name())\
		.replace(GdUnitHtmlPatterns.SKIPPED_COUNT, str(skipped_count()))\
		.replace(GdUnitHtmlPatterns.ORPHAN_COUNT, str(orphan_count()))\
		.replace(GdUnitHtmlPatterns.DURATION, LocalTime.elapsed(_duration))\
		.replace(GdUnitHtmlPatterns.FAILURE_REPORT, failure_report())


func update(report :GdUnitTestCaseReport) -> void:
	_error_count += report.error_count()
	_failure_count += report.failure_count()
	_orphan_count += report.orphan_count()
	_skipped_count += report.skipped_count()
	_failure_reports += report._failure_reports
	_duration += report.duration()
