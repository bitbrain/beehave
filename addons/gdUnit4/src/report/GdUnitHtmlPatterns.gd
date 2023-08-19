class_name GdUnitHtmlPatterns
extends RefCounted

const TABLE_RECORD_TESTSUITE = """
								<tr>
									<td><a class="${report_state}" href=${report_link}>${testsuite_name}</a></td>
									<td>${test_count}</td>
									<td>${skipped_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="${report_state}">${success_percent}</td>
								</tr>
"""

const TABLE_RECORD_PATH = """
								<tr>
									<td><a class="${report_state}" href="${report_link}">${path}</a></td>
									<td>${test_count}</td>
									<td>${skipped_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="${report_state}">${success_percent}</td>
								</tr>
"""


const TABLE_REPORT_TESTSUITE = """
								<tr>
									<td class="${report_state}">TestSuite hooks</td>
									<td>n/a</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="report-column">${failure-report}</td>
								</tr>
"""


const TABLE_RECORD_TESTCASE = """
								<tr>
									<td class="${report_state}">${testcase_name}</td>
									<td>${skipped_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="report-column">${failure-report}</td>
								</tr>
"""

const TABLE_BY_PATHS = "${report_table_paths}"
const TABLE_BY_TESTSUITES = "${report_table_testsuites}"
const TABLE_BY_TESTCASES = "${report_table_tests}"

# the report state success, error, warning
const REPORT_STATE = "${report_state}"
const PATH = "${path}"
const TESTSUITE_COUNT = "${suite_count}"
const TESTCASE_COUNT = "${test_count}"
const FAILURE_COUNT = "${failure_count}"
const SKIPPED_COUNT = "${skipped_count}"
const ORPHAN_COUNT = "${orphan_count}"
const DURATION = "${duration}"
const FAILURE_REPORT = "${failure-report}"
const SUCCESS_PERCENT = "${success_percent}"

const TESTSUITE_NAME = "${testsuite_name}"
const TESTCASE_NAME = "${testcase_name}"
const REPORT_LINK = "${report_link}"
const BREADCRUMP_PATH_LINK = "${breadcrumb_path_link}"
const BUILD_DATE = "${buid_date}"


static func current_date() -> String:
	return Time.get_datetime_string_from_system(true, true)


static func build(template :String, report :GdUnitReportSummary, report_link :String) -> String:
	return template\
		.replace(PATH, report.path())\
		.replace(TESTSUITE_NAME, report.name())\
		.replace(TESTSUITE_COUNT, str(report.suite_count()))\
		.replace(TESTCASE_COUNT, str(report.test_count()))\
		.replace(FAILURE_COUNT, str(report.error_count() + report.failure_count()))\
		.replace(SKIPPED_COUNT, str(report.skipped_count()))\
		.replace(ORPHAN_COUNT, str(report.orphan_count()))\
		.replace(DURATION, LocalTime.elapsed(report.duration()))\
		.replace(SUCCESS_PERCENT, report.calculate_succes_rate(report.test_count(), report.error_count(), report.failure_count()))\
		.replace(REPORT_STATE, report.report_state())\
		.replace(REPORT_LINK, report_link)\
		.replace(BUILD_DATE, current_date())


static func load_template(template_name :String) -> String:
	return FileAccess.open(template_name, FileAccess.READ).get_as_text()
