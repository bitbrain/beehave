extends GdUnitFuncAssert


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")
const DEFAULT_TIMEOUT := 2000


var _current_value_provider :ValueProvider
var _current_error_message :String = ""
var _custom_failure_message :String = ""
var _line_number := -1
var _timeout := DEFAULT_TIMEOUT
var _interrupted := false
var _sleep_timer :Timer = null


func _init(instance :Object, func_name :String, args := Array()):
	_line_number = GdUnitAssertions.get_line_number()
	GdAssertReports.reset_last_error_line_number()
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	# verify at first the function name exists
	if not instance.has_method(func_name):
		report_error("The function '%s' do not exists checked instance '%s'." % [func_name, instance])
		_interrupted = true
	else:
		_current_value_provider = CallBackValueProvider.new(instance, func_name, args)


func _notification(_what):
	if is_instance_valid(_current_value_provider):
		_current_value_provider.dispose()
		_current_value_provider = null
	if is_instance_valid(_sleep_timer):
		Engine.get_main_loop().root.remove_child(_sleep_timer)
		_sleep_timer.stop()
		_sleep_timer.free()
		_sleep_timer = null


func report_success() -> GdUnitFuncAssert:
	GdAssertReports.report_success()
	return self


func report_error(error_message :String) -> GdUnitFuncAssert:
	_current_error_message = error_message if _custom_failure_message == "" else _custom_failure_message
	GdAssertReports.report_error(_current_error_message, _line_number)
	return self


func failure_message() -> String:
	return _current_error_message


func send_report(report :GdUnitReport)-> void:
	GdUnitSignals.instance().gdunit_report.emit(report)


func override_failure_message(message :String) -> GdUnitFuncAssert:
	_custom_failure_message = message
	return self


func wait_until(timeout := 2000) -> GdUnitFuncAssert:
	if timeout <= 0:
		push_warning("Invalid timeout param, alloed timeouts must be grater than 0. Use default timeout instead")
		_timeout = DEFAULT_TIMEOUT
	else:
		_timeout = timeout
	return self


func is_null() -> GdUnitFuncAssert:
	await _validate_callback(cb_is_null)
	return self


func is_not_null() -> GdUnitFuncAssert:
	await _validate_callback(cb_is_not_null)
	return self


func is_false() -> GdUnitFuncAssert:
	await _validate_callback(cb_is_false)
	return self


func is_true() -> GdUnitFuncAssert:
	await _validate_callback(cb_is_true)
	return self


func is_equal(expected) -> GdUnitFuncAssert:
	await _validate_callback(cb_is_equal, expected)
	return self


func is_not_equal(expected) -> GdUnitFuncAssert:
	await _validate_callback(cb_is_not_equal, expected)
	return self


# we need actually to define this Callable as functions otherwise we results into leaked scripts here
# this is actually a Godot bug and needs this kind of workaround
func cb_is_null(c, _e): return c == null
func cb_is_not_null(c, _e): return c != null
func cb_is_false(c, _e): return c == false
func cb_is_true(c, _e): return c == true
func cb_is_equal(c, e): return GdObjects.equals(c,e)
func cb_is_not_equal(c, e): return not GdObjects.equals(c, e)


func _validate_callback(predicate :Callable, expected = null):
	if _interrupted:
		return
	GdUnitMemoryObserver.guard_instance(self)
	var time_scale = Engine.get_time_scale()
	var timer := Timer.new()
	timer.set_name("gdunit_funcassert_interrupt_timer_%d" % timer.get_instance_id())
	Engine.get_main_loop().root.add_child(timer)
	timer.add_to_group("GdUnitTimers")
	timer.timeout.connect(func do_interrupt():
		_interrupted = true
		, CONNECT_DEFERRED)
	timer.set_one_shot(true)
	timer.start((_timeout/1000.0)*time_scale)
	_sleep_timer = Timer.new()
	_sleep_timer.set_name("gdunit_funcassert_sleep_timer_%d" % _sleep_timer.get_instance_id() )
	Engine.get_main_loop().root.add_child(_sleep_timer)

	while true:
		var current = await next_current_value()
		# is interupted or predicate success
		if _interrupted or predicate.call(current, expected):
			break
		if is_instance_valid(_sleep_timer):
			_sleep_timer.start(0.05)
			await _sleep_timer.timeout

	_sleep_timer.stop()
	await Engine.get_main_loop().process_frame
	if _interrupted:
		# https://github.com/godotengine/godot/issues/73052
		#var predicate_name = predicate.get_method()
		var predicate_name :String = str(predicate).split('::')[1]
		report_error(GdAssertMessages.error_interrupted(predicate_name.strip_edges().trim_prefix("cb_"), expected, LocalTime.elapsed(_timeout)))
	else:
		report_success()
	_sleep_timer.free()
	timer.free()
	GdUnitMemoryObserver.unguard_instance(self)


func next_current_value() -> Variant:
	@warning_ignore("redundant_await")
	if is_instance_valid(_current_value_provider):
		return await _current_value_provider.get_value()
	return "invalid value"
