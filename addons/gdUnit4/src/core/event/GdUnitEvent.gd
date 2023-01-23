class_name GdUnitEvent
extends Resource


const WARNINGS = "warnings"
const FAILED = "failed"
const ERRORS = "errors"
const SKIPPED = "skipped"
const ELAPSED_TIME = "elapsed_time"
const ORPHAN_NODES = "orphan_nodes"
const ERROR_COUNT = "error_count"
const FAILED_COUNT = "failed_count"
const SKIPPED_COUNT = "skipped_count"

enum  {
	INIT,
	STOP,
	TESTSUITE_BEFORE,
	TESTSUITE_AFTER,
	TESTCASE_BEFORE,
	TESTCASE_AFTER,
}

var _event_type :int
var _resource_path :String
var _suite_name :String
var _test_name :String
var _total_count :int = 0
var _statistics := Dictionary()
var _reports := Array()

func suite_before(resource_path :String, suite_name :String, total_count) -> GdUnitEvent:
	_event_type = TESTSUITE_BEFORE
	_resource_path = resource_path
	_suite_name = suite_name
	_test_name = "before"
	_total_count = total_count
	return self

func suite_after(resource_path :String, suite_name :String, statistics :Dictionary = {}, reports :Array = []) -> GdUnitEvent:
	_event_type = TESTSUITE_AFTER
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = "after"
	_statistics = statistics
	_reports = reports
	return self

func test_before(resource_path :String, suite_name:String, test_name:String) -> GdUnitEvent:
	_event_type = TESTCASE_BEFORE
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = test_name
	return self

func test_after(resource_path :String, suite_name :String, test_name :String, statistics :Dictionary = {}, reports :Array = []) -> GdUnitEvent:
	_event_type = TESTCASE_AFTER
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = test_name
	_statistics = statistics
	_reports = reports
	return self

func type() -> int:
	return _event_type

func suite_name() -> String:
	return _suite_name

func test_name() -> String:
	return _test_name

func elapsed_time() -> int:
	return _statistics.get(ELAPSED_TIME, 0)

func orphan_nodes() -> int:
	return  _statistics.get(ORPHAN_NODES, 0)

func statistic(type :String) -> int:
	return _statistics.get(type, 0)

func total_count() -> int:
	return _total_count

func success_count() -> int:
	return total_count() - error_count() - failed_count() - skipped_count()

func error_count() -> int:
	return _statistics.get(ERROR_COUNT, 0)
	
func failed_count() -> int:
	return _statistics.get(FAILED_COUNT, 0)
	
func skipped_count() -> int:
	return _statistics.get(SKIPPED_COUNT, 0)

func resource_path() -> String:
	return _resource_path

func is_success() -> bool:
	return not is_warning() and not is_failed() and not is_error() and not is_skipped()

func is_warning() -> bool:
	return _statistics.get(WARNINGS, false)

func is_failed() -> bool:
	return _statistics.get(FAILED, false)

func is_error() -> bool:
	return _statistics.get(ERRORS, false)

func is_skipped() -> bool:
	return _statistics.get(SKIPPED, false)

func reports() -> Array:
	return _reports

func _to_string():
	return "Event: %d %s:%s, %s, %s" % [_event_type, _suite_name, _test_name, _statistics, _reports]

func serialize() -> Dictionary:
	var serialized := {
		"type"         : _event_type,
		"resource_path": _resource_path,
		"suite_name"   : _suite_name,
		"test_name"    : _test_name,
		"total_count"  : _total_count,
		"statistics"    : _statistics
	}
	serialized["reports"] = _serialize_TestReports()
	return serialized

func deserialize(serialized :Dictionary) -> GdUnitEvent:
	_event_type    = serialized.get("type", null)
	_resource_path = serialized.get("resource_path", null)
	_suite_name    = serialized.get("suite_name", null)
	_test_name     = serialized.get("test_name", "unknown")
	_total_count   = serialized.get("total_count", 0)
	_statistics     = serialized.get("statistics", Dictionary())
	_reports       = _deserialize_reports(serialized.get("reports",[]))
	return self

func _serialize_TestReports() -> Array:
	var serialized_reports := Array()
	for report in _reports:
		serialized_reports.append(report.serialize())
	return serialized_reports

func _deserialize_reports(reports :Array) -> Array:
	var deserialized_reports := Array()
	for report in reports:
		var test_report := GdUnitReport.new().deserialize(report)
		deserialized_reports.append(test_report)
	return deserialized_reports
	
