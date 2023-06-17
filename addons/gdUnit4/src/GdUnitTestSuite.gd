## The main class for all GdUnit test suites[br]
## This class is the main class to implement your unit tests[br]
## You have to extend and implement your test cases as described[br]
## e.g MyTests.gd [br]
## [codeblock]
## 	extends GdUnitTestSuite
## 	# testcase
## 	func test_testCaseA():
## 	    assert_that("value").is_equal("value")
## [/codeblock][br]
## @tutorial:  https://mikeschulze.github.io/gdUnit4/faq/test-suite/

@icon("res://addons/gdUnit4/src/ui/assets/TestSuite.svg")
class_name GdUnitTestSuite
extends Node


const NO_ARG = GdUnitConstants.NO_ARG

## This function is called before a test suite starts[br]
## You can overwrite to prepare test data or initalizize necessary variables
func before() -> void:
	pass


## This function is called at least when a test suite is finished[br]
## You can overwrite to cleanup data created during test running
func after() -> void:
	pass


## This function is called before a test case starts[br]
## You can overwrite to prepare test case specific data
func before_test() -> void:
	pass


## This function is called after the test case is finished[br]
## You can overwrite to cleanup your test case specific data
func after_test() -> void:
	pass


## Skip the test-suite from execution, it will be ignored
func skip(skipped :bool) -> void:
	set_meta("gd_skipped", skipped)


func is_failure(_expected_failure :String = NO_ARG) -> bool:
	return Engine.get_meta("GD_TEST_FAILURE") if Engine.has_meta("GD_TEST_FAILURE") else false


func is_skipped() -> bool:
	return get_meta("gd_skipped") if has_meta("gd_skipped") else false


var __active_test_case :String
func set_active_test_case(test_case :String) -> void:
	__active_test_case = test_case


# === Tools ====================================================================
# Mapps Godot error number to a readable error message. See at ERROR
# https://docs.godotengine.org/de/stable/classes/class_@globalscope.html#enum-globalscope-error
func error_as_string(error_number :int) -> String:
	return GdUnitTools.error_as_string(error_number)


## A litle helper to auto freeing your created objects after test execution
func auto_free(obj) -> Variant:
	return GdUnitMemoryPool.register_auto_free(obj, get_meta(GdUnitMemoryPool.META_PARAM))


## Discard the error message triggered by a timeout (interruption).[br]
## By default, an interrupted test is reported as an error.[br]
## This function allows you to change the message to Success when an interrupted error is reported.
func discard_error_interupted_by_timeout() -> void:
	GdUnitTools.register_expect_interupted_by_timeout(self, __active_test_case)


## Creates a new directory under the temporary directory *user://tmp*[br]
## Useful for storing data during test execution. [br]
## The directory is automatically deleted after test suite execution
func create_temp_dir(relative_path :String) -> String:
	return GdUnitTools.create_temp_dir(relative_path)


## Deletes the temporary base directory[br]
## Is called automatically after each execution of the test suite
func clean_temp_dir():
	GdUnitTools.clear_tmp()


## Creates a new file under the temporary directory *user://tmp* + <relative_path>[br]
## with given name <file_name> and given file <mode> (default = File.WRITE)[br]
## If success the returned File is automatically closed after the execution of the test suite
func create_temp_file(relative_path :String, file_name :String, mode := FileAccess.WRITE) -> FileAccess:
	return GdUnitTools.create_temp_file(relative_path, file_name, mode)


## Reads a resource by given path <resource_path> into a PackedStringArray.
func resource_as_array(resource_path :String) -> PackedStringArray:
	return GdUnitTools.resource_as_array(resource_path)


## Reads a resource by given path <resource_path> and returned the content as String.
func resource_as_string(resource_path :String) -> String:
	return GdUnitTools.resource_as_string(resource_path)


## Reads a resource by given path <resource_path> and return Variand translated by str_to_var
func resource_as_var(resource_path :String):
	return str_to_var(GdUnitTools.resource_as_string(resource_path))


## clears the debuger error list[br]
## PROTOTYPE!!!! Don't use it for now
func clear_push_errors() -> void:
	GdUnitTools.clear_push_errors()


## Waits for given signal is emited by the <source> until a specified timeout to fail[br]
## source: the object from which the signal is emitted[br]
## signal_name: signal name[br]
## args: the expected signal arguments as an array[br]
## timeout: the timeout in ms, default is set to 2000ms
func await_signal_on(source :Object, signal_name :String, args :Array = [], timeout :int = 2000) -> Variant:
	# fail fast if the given source instance invalid
	if not is_instance_valid(source):
		GdUnitAssertImpl.new(signal_name)\
			.report_error(GdAssertMessages.error_await_signal_on_invalid_instance(source, signal_name, args), GdUnitAssertImpl._get_line_number())
		return await GdUnitAwaiter.await_idle_frame()
	return await GdUnitAwaiter.await_signal_on(source, signal_name, args, timeout)


## Waits until the next idle frame
func await_idle_frame():
	await GdUnitAwaiter.await_idle_frame()


## Waits for for a given amount of milliseconds[br]
## example:[br]
## [codeblock]
##    # waits for 100ms
##    await await_millis(myNode, 100).completed
## [/codeblock][br]
## use this waiter and not `await get_tree().create_timer().timeout to prevent errors when a test case is timed out
func await_millis(timeout :int):
	await GdUnitAwaiter.await_millis(timeout)


## Creates a new scene runner to allow simulate interactions checked a scene.[br]
## The runner will manage the scene instance and release after the runner is released[br]
## example:[br]
## [codeblock]
##    # creates a runner by using a instanciated scene
##    var scene = load("res://foo/my_scne.tscn").instantiate() 
##    var runner := scene_runner(scene)
##
##    # or simply creates a runner by using the scene resource path
##    var runner := scene_runner("res://foo/my_scne.tscn")
## [/codeblock]
func scene_runner(scene, verbose := false) -> GdUnitSceneRunner:
	return auto_free(GdUnitSceneRunnerImpl.new(scene, verbose))


# === Mocking  & Spy ===========================================================

## do return a default value for primitive types or null 
const RETURN_DEFAULTS = GdUnitMock.RETURN_DEFAULTS
## do call the real implementation
const CALL_REAL_FUNC = GdUnitMock.CALL_REAL_FUNC
## do return a default value for primitive types and a fully mocked value for Object types
## builds full deep mocked object
const RETURN_DEEP_STUB = GdUnitMock.RETURN_DEEP_STUB


## Creates a mock for given class name
func mock(clazz, mock_mode := RETURN_DEFAULTS) -> Object:
	return GdUnitMockBuilder.build(self, clazz, mock_mode)


## Creates a spy checked given object instance
func spy(instance):
	return GdUnitSpyBuilder.build(self, instance)


## Configures a return value for the specified function and used arguments.[br]
## [b]Example:
## 	[codeblock]
## 		# overrides the return value of myMock.is_selected() to false
## 		do_return(false).on(myMock).is_selected()
## 	[/codeblock]
func do_return(value) -> GdUnitMock:
	return GdUnitMock.new(value)


## Verifies certain behavior happened at least once or exact number of times
func verify(obj, times := 1):
	return GdUnitObjectInteractions.verify(obj, times)


## Verifies no interactions is happen checked this mock or spy
func verify_no_interactions(obj) -> GdUnitAssert:
	return GdUnitObjectInteractions.verify_no_interactions(obj)


## Verifies the given mock or spy has any unverified interaction.
func verify_no_more_interactions(obj) -> GdUnitAssert:
	return GdUnitObjectInteractions.verify_no_more_interactions(obj)


## Resets the saved function call counters checked a mock or spy
func reset(obj) -> void:
	GdUnitObjectInteractions.reset(obj)


## Starts monitoring the specified source to collect all transmitted signals.[br]
## The collected signals can then be checked with 'assert_signal'.[br]
## By default, the specified source is automatically released when the test ends.
## You can control this behavior by setting auto_free to false if you do not want the source to be automatically freed.[br]
## Usage:
##	[codeblock]
##		var emitter := monitor_signals(MyEmitter.new())
##		# call the function to send the signal
##		emitter.do_it()
##		# verify the signial is emitted
##		await assert_signal(emitter).is_emitted('my_signal')
##	[/codeblock]
func monitor_signals(source :Object, _auto_free := true) -> Object:
	var signal_collector := GdUnitThreadManager.get_current_context().get_signal_collector()
	signal_collector.register_emitter(source)
	return auto_free(source) if _auto_free else source


# === Argument matchers ========================================================
## Argument matcher to match any argument
func any() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any()


## Argument matcher to match any boolean value
func any_bool() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_BOOL)


## Argument matcher to match any integer value
func any_int() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_INT)


## Argument matcher to match any float value
func any_float() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_FLOAT)


## Argument matcher to match any string value
func any_string() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_STRING)


## Argument matcher to match any Color value
func any_color() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_COLOR)


## Argument matcher to match any Vector typed value
func any_vector() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_types([
		TYPE_VECTOR2,
		TYPE_VECTOR2I,
		TYPE_VECTOR3,
		TYPE_VECTOR3I,
		TYPE_VECTOR4,
		TYPE_VECTOR4I,
	])


## Argument matcher to match any Vector2 value
func any_vector2() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR2)


## Argument matcher to match any Vector2i value
func any_vector2i() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR2I)


## Argument matcher to match any Vector3 value
func any_vector3() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR3)


## Argument matcher to match any Vector3i value
func any_vector3i() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR3I)


## Argument matcher to match any Vector4 value
func any_vector4() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR4)


## Argument matcher to match any Vector3i value
func any_vector4i() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_VECTOR4I)


## Argument matcher to match any Rect2 value
func any_rect2() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_RECT2)


## Argument matcher to match any Plane value
func any_plane() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PLANE)


## Argument matcher to match any Quaternion value
func any_quat() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_QUATERNION)


## Argument matcher to match any AABB value
func any_aabb() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_AABB)


## Argument matcher to match any Basis value
func any_basis() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_BASIS)


## Argument matcher to match any Transform3D value
func any_transform() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_TRANSFORM3D)


## Argument matcher to match any Transform2D value
func any_transform_2d() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_TRANSFORM2D)


## Argument matcher to match any NodePath value
func any_node_path() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_NODE_PATH)


## Argument matcher to match any RID value
func any_rid() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_RID)


## Argument matcher to match any Object value
func any_object() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_OBJECT)


## Argument matcher to match any Dictionary value
func any_dictionary() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_DICTIONARY)


## Argument matcher to match any Array value
func any_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_ARRAY)


## Argument matcher to match any PackedByteArray value
func any_pool_byte_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_BYTE_ARRAY)


## Argument matcher to match any PackedInt32Array value
func any_pool_int_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_INT32_ARRAY)


## Argument matcher to match any PackedFloat32Array value
func any_pool_float_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_FLOAT32_ARRAY)


## Argument matcher to match any PackedStringArray value
func any_pool_string_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_STRING_ARRAY)


## Argument matcher to match any PackedVector2Array value
func any_pool_vector2_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_VECTOR2_ARRAY)


## Argument matcher to match any PackedVector3Array value
func any_pool_vector3_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_VECTOR3_ARRAY)


## Argument matcher to match any PackedColorArray value
func any_pool_color_array() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.by_type(TYPE_PACKED_COLOR_ARRAY)


## Argument matcher to match any instance of given class
func any_class(clazz :Object) -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_class(clazz)


# === value extract utils ======================================================
## Builds an extractor by given function name and optional arguments
func extr(func_name :String, args := Array()) -> GdUnitValueExtractor:
	return GdUnitFuncValueExtractor.new(func_name, args)


## Constructs a tuple by given arguments
func tuple(arg0, arg1=GdUnitTuple.NO_ARG, arg2=GdUnitTuple.NO_ARG, arg3=GdUnitTuple.NO_ARG, arg4=GdUnitTuple.NO_ARG, arg5=GdUnitTuple.NO_ARG, arg6=GdUnitTuple.NO_ARG, arg7=GdUnitTuple.NO_ARG, arg8=GdUnitTuple.NO_ARG, arg9=GdUnitTuple.NO_ARG) -> GdUnitTuple:
	return GdUnitTuple.new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)


# === Asserts ==================================================================

## The common assertion tool to verify values.
## It checks the given value by type to fit to the best assert
func assert_that(current) -> GdUnitAssert:
	
	if GdArrayTools.is_array_type(current):
		return assert_array(current)
	
	match typeof(current):
		TYPE_BOOL:
			return assert_bool(current)
		TYPE_INT:
			return assert_int(current)
		TYPE_FLOAT:
			return assert_float(current)
		TYPE_STRING:
			return assert_str(current)
		TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I:
			return assert_vector(current)
		TYPE_DICTIONARY:
			return assert_dict(current)
		TYPE_ARRAY:
			return assert_array(current)
		TYPE_OBJECT, TYPE_NIL:
			return assert_object(current)
		_:
			return GdUnitAssertImpl.new(current)


## An assertion tool to verify boolean values.
func assert_bool(current) -> GdUnitBoolAssert:
	return GdUnitBoolAssertImpl.new(current)


## An assertion tool to verify String values.
func assert_str(current) -> GdUnitStringAssert:
	return GdUnitStringAssertImpl.new(current)


## An assertion tool to verify integer values.
func assert_int(current) -> GdUnitIntAssert:
	return GdUnitIntAssertImpl.new(current)


## An assertion tool to verify float values.
func assert_float(current) -> GdUnitFloatAssert:
	return GdUnitFloatAssertImpl.new(current)


## An assertion tool to verify Vector values.[br]
## This assertion supports all vector types.[br]
## Usage:
##     [codeblock]
##		assert_vector(Vector2(1.2, 1.000001)).is_equal(Vector2(1.2, 1.000001))
##     [/codeblock]
func assert_vector(current) -> GdUnitVectorAssert:
	return GdUnitVectorAssertImpl.new(current)


## An assertion tool to verify Vector2 values.[br]
## This function is [b]deprecated[/b] you have to use [method assert_vector] instead
func assert_vector2(current) -> GdUnitVectorAssert:
	push_warning("assert_vector2 is deprecated, Use 'assert_vector' instead.")
	return assert_vector(current)


## An assertion tool to verify Vector3 values.[br]
## This function is [b]deprecated[/b] you have to use [method assert_vector] instead
func assert_vector3(current) -> GdUnitVectorAssert:
	push_warning("assert_vector3 is deprecated, Use 'assert_vector' instead.")
	return assert_vector(current)


## An assertion tool to verify arrays.
func assert_array(current) -> GdUnitArrayAssert:
	return GdUnitArrayAssertImpl.new(current)


## An assertion tool to verify dictionaries.
func assert_dict(current) -> GdUnitDictionaryAssert:
	return GdUnitDictionaryAssertImpl.new(current)


## An assertion tool to verify FileAccess.
func assert_file(current) -> GdUnitFileAssert:
	return GdUnitFileAssertImpl.new(current)


## An assertion tool to verify Objects.
func assert_object(current) -> GdUnitObjectAssert:
	return GdUnitObjectAssertImpl.new(current)


func assert_result(current) -> GdUnitResultAssert:
	return GdUnitResultAssertImpl.new(current)


## An assertion tool that waits until a certain time for an expected function return value
func assert_func(instance :Object, func_name :String, args := Array()) -> GdUnitFuncAssert:
	return GdUnitFuncAssertImpl.new(instance, func_name, args)


## An Assertion Tool to verify for emitted signals until a certain time.
func assert_signal(instance :Object) -> GdUnitSignalAssert:
	return GdUnitSignalAssertImpl.new(instance)


## Verifiys an assertion is failing as expected
## This assert is only designed for internal use to verify failing asserts working as expected
## Usage:
##     [codeblock]
##		assert_failure(func(): assert_bool(true).is_not_equal(true)) \
##			.has_message("Expecting:\n 'true'\n not equal to\n 'true'")
##     [/codeblock]
func assert_failure(assertion :Callable) -> GdUnitFailureAssert:
	return GdUnitFailureAssertImpl.new(assertion)


## Utility to check if a test has failed in a particular line and if there is an error message
func assert_failed_at(line_number :int, expected_failure :String) -> bool:
	var is_failed = is_failure()
	var last_failure = GdAssertReports.current_failure()
	var last_failure_line = GdAssertReports.get_last_error_line_number()
	assert_str(last_failure).is_equal(expected_failure)
	assert_int(last_failure_line).is_equal(line_number)
	GdAssertReports.expect_fail(true)
	return is_failed


func assert_not_yet_implemented():
	GdUnitAssertImpl.new(null).test_fail()


func fail(message :String):
	GdUnitAssertImpl.new(null).report_error(message)


# --- internal stuff do not override!!!
func ResourcePath() -> String:
	return get_script().resource_path
