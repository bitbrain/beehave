class_name GdUnitByPathReport
extends GdUnitReportSummary


func _init(path_ :String, reports_ :Array[GdUnitReportSummary]):
	_resource_path = path_
	_reports = reports_


static func sort_reports_by_path(reports_ :Array[GdUnitReportSummary]) -> Dictionary:
	var by_path := Dictionary()
	for report in reports_:
		var suite_path :String = report.path()
		var suite_report :Array[GdUnitReportSummary] = by_path.get(suite_path, [] as Array[GdUnitReportSummary])
		suite_report.append(report)
		by_path[suite_path] = suite_report
	return by_path


func path() -> String:
	return _resource_path.replace("res://", "")


func create_record(report_link :String) -> String:
	return GdUnitHtmlPatterns.build(GdUnitHtmlPatterns.TABLE_RECORD_PATH, self, report_link)


func write(report_dir :String) -> String:
	var template := GdUnitHtmlPatterns.load_template("res://addons/gdUnit4/src/report/template/folder_report.html")
	var path_report := GdUnitHtmlPatterns.build(template, self, "")
	path_report = apply_testsuite_reports(report_dir, path_report, _reports)
	
	var output_path := "%s/path/%s.html" % [report_dir, path().replace("/", ".")]
	var dir := output_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	FileAccess.open(output_path, FileAccess.WRITE).store_string(path_report)
	return output_path


func apply_testsuite_reports(report_dir :String, template :String, reports_ :Array[GdUnitReportSummary]) -> String:
	var table_records := PackedStringArray()
	
	for report in reports_:
		var report_link = report.output_path(report_dir).replace(report_dir, "..")
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_TESTSUITES, "\n".join(table_records))
