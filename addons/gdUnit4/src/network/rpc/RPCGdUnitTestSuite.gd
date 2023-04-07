class_name RPCGdUnitTestSuite
extends RPC

var _data :Dictionary

static func of(test_suite) -> RPCGdUnitTestSuite:
	var rpc = RPCGdUnitTestSuite.new()
	rpc._data = GdUnitTestSuiteDto.new().serialize(test_suite)
	return rpc

func dto() -> GdUnitResourceDto:
	return GdUnitTestSuiteDto.new().deserialize(_data)

func _to_string():
	return "RPCGdUnitTestSuite: " + str(_data)
