class_name _TestCase
extends Node

signal completed()

# default timeout 5min
const DEFAULT_TIMEOUT := -1
const ARGUMENT_TIMEOUT := "timeout"

var _iterations: int = 1
var _seed: int
var _fuzzers: Array[GdFunctionArgument] = []
var _test_parameters := Array()
var _test_param_index := -1
var _line_number: int = -1
var _script_path: String
var _skipped := false
var _error := ""
var _expect_to_interupt := false
var _timer : Timer
var _interupted :bool = false
var _timeout :int
var _default_timeout :int
var _monitor := GodotGdErrorMonitor.new()


func _init():
	_default_timeout = GdUnitSettings.test_timeout()


func configure(name: String, line_number: int, script_path: String, timeout :int = DEFAULT_TIMEOUT, fuzzers :Array = [], iterations: int = 1, seed_ :int = -1, skipped := false) -> _TestCase:
	set_name(name)
	_line_number = line_number
	_fuzzers = fuzzers
	_iterations = iterations
	_seed = seed_
	_script_path = script_path
	_skipped = skipped
	_timeout = _default_timeout
	if timeout != DEFAULT_TIMEOUT:
		_timeout = timeout
	return self


func execute(test_parameter := Array(), iteration := 0):
	if iteration == 0:
		set_timeout()
	_monitor.start()
	if not test_parameter.is_empty():
		update_fuzzers(test_parameter, iteration)
		_execute_test_case(name, test_parameter) 
	else:
		_execute_test_case(name, [])
	await completed
	_monitor.stop()
	for report in _monitor.reports():
		GdUnitAssertImpl.new(get_parent(), null).send_report(report)


func dispose():
	stop_timer()


func _execute_test_case(name :String, test_parameter :Array):
	# needs at least on await otherwise it braks the awaiting chain
	await get_parent().callv(name, test_parameter)
	await get_tree().create_timer(0.0001).timeout
	completed.emit()


func update_fuzzers(input_values :Array, iteration :int):
	for fuzzer in input_values:
		if fuzzer is Fuzzer:
			fuzzer._iteration_index = iteration + 1


func set_timeout():
	var time :float = _timeout * 0.001
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.connect('timeout', Callable(self, '_test_case_timeout'))
	_timer.set_wait_time(time)
	_timer.set_autostart(false)
	_timer.start()


func _test_case_timeout():
	_interupted = true
	completed.emit()


func stop_timer() :
	# finish outstanding timeouts
	if is_instance_valid(_timer):
		if _timer.is_connected("timeout", Callable(self, '_test_case_timeout')):
			_timer.disconnect("timeout", Callable(self, '_test_case_timeout'))
		_timer.stop()
		_timer.call_deferred("free")


func expect_to_interupt() -> void:
	_expect_to_interupt = true


func is_interupted() -> bool:
	return _interupted


func is_expect_interupted() -> bool:
	return _expect_to_interupt


func is_parameterized() -> bool:
	return _test_parameters.size() != 0


func is_skipped() -> bool:
	return _skipped


func error() -> String:
	return _error


func line_number() -> int:
	return _line_number


func iterations() -> int:
	return _iterations


func timeout() -> int:
	return _timeout


func seed_value() -> int:
	return _seed


func has_fuzzer() -> bool:
	return not _fuzzers.is_empty()


func fuzzer_arguments() -> Array[GdFunctionArgument]:
	return _fuzzers


func script_path() -> String:
	return _script_path


func ResourcePath() -> String:
	return _script_path


func generate_seed() -> void:
	if _seed != -1:
		seed(_seed)


func skip(skipped :bool, error :String = "") -> void:
	_skipped = skipped
	_error = error


func set_test_parameters(test_parameters :Array) -> void:
	_test_parameters = test_parameters


func set_test_parameter_index(index :int) -> void:
	_test_param_index = index


func test_parameters() -> Array:
	return _test_parameters


func test_parameter_index() -> int:
	return _test_param_index


func test_case_names() -> PackedStringArray:
	var test_case_names :=  PackedStringArray()
	var test_name = get_name()
	for index in _test_parameters.size():
		test_case_names.append("%s:%d %s" % [test_name, index, str(_test_parameters[index])])
	return test_case_names


func _to_string():
	return "%s :%d (%dms)" % [get_name(), _line_number, _timeout]
