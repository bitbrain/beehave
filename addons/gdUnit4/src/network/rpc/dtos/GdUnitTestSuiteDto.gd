class_name GdUnitTestSuiteDto
extends GdUnitResourceDto

var _test_cases_by_name := Dictionary()

func serialize(test_suite :Node) -> Dictionary:
	var serialized := super.serialize(test_suite)
	var test_cases := Array()
	serialized["test_cases"] = test_cases
	for test_case in test_suite.get_children():
		test_cases.append(GdUnitTestCaseDto.new().serialize(test_case))
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	super.deserialize(data)
	var test_cases :Array = data.get("test_cases", Array())
	for test_case in test_cases:
		add_test_case(GdUnitTestCaseDto.new().deserialize(test_case))
	return self

func add_test_case(test_case :GdUnitTestCaseDto):
	_test_cases_by_name[test_case.name()] = test_case

func test_case_count() -> int:
	return _test_cases_by_name.size()

func test_cases() -> Array:
	return _test_cases_by_name.values()
