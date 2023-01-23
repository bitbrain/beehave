class_name GdUnitTestCaseDto
extends GdUnitResourceDto

var _line_number :int = -1
var _test_case_names :PackedStringArray = []

func serialize(test_case) -> Dictionary:
	var serialized := super.serialize(test_case)
	if test_case.has_method("line_number"):
		serialized["line_number"] = test_case.line_number()
	else:
		serialized["line_number"] = test_case.get("LineNumber")
	if test_case.has_method("test_case_names"):
		serialized["test_case_names"] = test_case.test_case_names()
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	super.deserialize(data)
	_line_number = data.get("line_number", -1)
	_test_case_names = data.get("test_case_names", [])
	return self

func line_number() -> int:
	return _line_number

func test_case_names() -> PackedStringArray:
	return _test_case_names
