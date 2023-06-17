class_name GdAssertMessages
extends Resource

const WARN_COLOR = "#EFF883"
const ERROR_COLOR = "#CD5C5C"
const VALUE_COLOR = "#1E90FF"
const SUB_COLOR :=  Color(1, 0, 0, .3)
const ADD_COLOR :=  Color(0, 1, 0, .3)


static func _format_dict(value :Dictionary) -> String:
	if value.is_empty():
		return "{ }"
	var as_rows := var_to_str(value).split("\n")
	for index in range( 1, as_rows.size()-1):
		as_rows[index] = "	" + as_rows[index]
	as_rows[-1] = "  " + as_rows[-1]
	return "\n".join(as_rows)


# improved version of InputEvent as text
static func input_event_as_text(event :InputEvent) -> String:
	var text := ""
	if event is InputEventKey:
		text += "InputEventKey : key='%s', pressed=%s, keycode=%d, physical_keycode=%s" % [event.as_text(), event.pressed, event.keycode, event.physical_keycode]
	else:
		text += event.as_text()
	if event is InputEventMouse:
		text += ", global_position %s" % event.global_position
	if event is InputEventWithModifiers:
		text += ", shift=%s, alt=%s, control=%s, meta=%s, command=%s" % [event.shift_pressed, event.alt_pressed, event.ctrl_pressed, event.meta_pressed, event.command_or_control_autoremap]
	return text


static func _colored_string_div(characters :String) -> String:
	return _colored_array_div(characters.to_ascii_buffer())


static func _colored_array_div(characters :PackedByteArray) -> String:
	if characters.is_empty():
		return "<empty>"
	var result = PackedByteArray()
	var index = 0
	var missing_chars := PackedByteArray()
	var additional_chars := PackedByteArray()
	
	while index < characters.size():
		var character := characters[index]
		match character:
			GdDiffTool.DIV_ADD:
				index += 1
				additional_chars.append(characters[index])
			GdDiffTool.DIV_SUB:
				index += 1
				missing_chars.append(characters[index])
			_:
				if not missing_chars.is_empty():
					result.append_array(format_chars(missing_chars, SUB_COLOR))
					missing_chars = PackedByteArray()
				if not additional_chars.is_empty():
					result.append_array(format_chars(additional_chars, ADD_COLOR))
					additional_chars = PackedByteArray()
				result.append(character)
		index += 1
	
	result.append_array(format_chars(missing_chars, SUB_COLOR))
	result.append_array(format_chars(additional_chars, ADD_COLOR))
	return result.get_string_from_utf8()


static func _typed_value(value) -> String:
	return GdDefaultValueDecoder.decode(value)


static func _warning(error :String) -> String:
	return "[color=%s]%s[/color]" % [WARN_COLOR, error]


static func _error(error :String) -> String:
	return "[color=%s]%s[/color]" % [ERROR_COLOR, error]


static func _nerror(number) -> String:
	match typeof(number):
		TYPE_INT:
			return "[color=%s]%d[/color]" % [ERROR_COLOR, number]
		TYPE_FLOAT:
			return "[color=%s]%f[/color]" % [ERROR_COLOR, number]
		_:
			return "[color=%s]%s[/color]" % [ERROR_COLOR, str(number)]


static func _colored_value(value, _delimiter ="\n") -> String:
	match typeof(value):
		TYPE_STRING, TYPE_STRING_NAME:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, _colored_string_div(value)]
		TYPE_INT:
			return "'[color=%s]%d[/color]'" % [VALUE_COLOR, value]
		TYPE_FLOAT:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, _typed_value(value)]
		TYPE_COLOR:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, _typed_value(value)]
		TYPE_OBJECT:
			if value == null:
				return "'[color=%s]<null>[/color]'" % [VALUE_COLOR]
			if value is InputEvent:
				return "[color=%s]<%s>[/color]" % [VALUE_COLOR, input_event_as_text(value)]
			if value.has_method("_to_string"):
				return "[color=%s]<%s>[/color]" % [VALUE_COLOR, value._to_string()]
			return "[color=%s]<%s>[/color]" % [VALUE_COLOR, value.get_class()]
		TYPE_DICTIONARY:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, _format_dict(value)]
		_:
			if GdArrayTools.is_array_type(value):
				return "'[color=%s]%s[/color]'" % [VALUE_COLOR, _typed_value(value)]
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, value]


static func _index_report_as_table(index_reports :Array) -> String:
	var table := "[table=3]$cells[/table]"
	var header := "[cell][right][b]$text[/b][/right]\t[/cell]"
	var cell := "[cell][right]$text[/right]\t[/cell]"
	var cells := header.replace("$text", "Index") + header.replace("$text", "Current") + header.replace("$text", "Expected")
	for report in index_reports:
		var index :String = str(report["index"])
		var current :String = str(report["current"])
		var expected :String = str(report["expected"])
		cells += cell.replace("$text", index) + cell.replace("$text", current) + cell.replace("$text", expected)
	return table.replace("$cells", cells)


static func orphan_detected_on_suite_setup(count :int):
	return "%s\n Detected <%d> orphan nodes during test suite setup stage! [b]Check before() and after()![/b]" % [
		_warning("WARNING:"), count]


static func orphan_detected_on_test_setup(count :int):
	return "%s\n Detected <%d> orphan nodes during test setup! [b]Check before_test() and after_test()![/b]" % [
		_warning("WARNING:"), count]


static func orphan_detected_on_test(count :int):
	return "%s\n Detected <%d> orphan nodes during test execution!" % [
		_warning("WARNING:"), count]


static func fuzzer_interuped(iterations: int, error: String) -> String:
	return "%s %s %s\n %s" % [
		_error("Found an error after"), 
		_colored_value(iterations + 1), 
		_error("test iterations"), 
		error]


static func test_timeout(timeout :int) -> String:
	return "%s\n %s" % [_error("Timeout !"), _colored_value("Test timed out after %s" %  LocalTime.elapsed(timeout))]


static func test_skipped(hint :String) -> String:
	return "%s\n %s" % [_error("This test is skipped!"), "Reason: %s" % _colored_value(hint)]


static func error_not_implemented() -> String:
	return _error("Test not implemented!")


static func error_is_null(current) -> String:
	return "%s %s but was %s" % [_error("Expecting:"), _colored_value(null), _colored_value(current)]


static func error_is_not_null() -> String:
	return "%s %s" % [_error("Expecting: not to be"), _colored_value(null)]


static func error_equal(current, expected, index_reports :Array = []) -> String:
	var report = """
		%s
		 %s
		 but was
		 %s""".dedent().trim_prefix("\n") % [_error("Expecting:"), _colored_value(expected, true), _colored_value(current, true)]
	if not index_reports.is_empty():
		report += "\n\n%s\n%s" % [_error("Differences found:"), _index_report_as_table(index_reports)]
	return report


static func error_not_equal(current, expected) -> String:
	return "%s\n %s\n not equal to\n %s" % [_error("Expecting:"), _colored_value(expected, true), _colored_value(current, true)]


static func error_not_equal_case_insensetiv(current, expected) -> String:
	return "%s\n %s\n not equal to (case insensitiv)\n %s" % [_error("Expecting:"), _colored_value(expected, true), _colored_value(current, true)]


static func error_is_empty(current) -> String:
	return "%s\n must be empty but was\n %s" % [_error("Expecting:"), _colored_value(current)]


static func error_is_not_empty() -> String:
	return "%s\n must not be empty" % [_error("Expecting:")]


static func error_is_same(current, expected) -> String:
	return "%s\n %s\n to refer to the same object\n %s" % [_error("Expecting:"), _colored_value(expected), _colored_value(current)]


@warning_ignore("unused_parameter")
static func error_not_same(current, expected) -> String:
	return "%s\n %s" % [_error("Expecting not same:"), _colored_value(expected)]


static func error_not_same_error(current, expected) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting error message:"), _colored_value(expected), _colored_value(current)]


static func error_is_instanceof(current: Result, expected :Result) -> String:
	return "%s\n %s\n But it was %s" % [_error("Expected instance of:"),\
		_colored_value(expected.or_else(null)), _colored_value(current.or_else(null))]


# -- Boolean Assert specific messages -----------------------------------------------------
static func error_is_true(current) -> String:
	return "%s %s but is %s" % [_error("Expecting:"), _colored_value(true), _colored_value(current)]


static func error_is_false(current) -> String:
	return "%s %s but is %s" % [_error("Expecting:"), _colored_value(false), _colored_value(current)]


# - Integer/Float Assert specific messages -----------------------------------------------------

static func error_is_even(current) -> String:
	return "%s\n %s must be even" % [_error("Expecting:"), _colored_value(current)]


static func error_is_odd(current) -> String:
	return "%s\n %s must be odd" % [_error("Expecting:"), _colored_value(current)]


static func error_is_negative(current) -> String:
	return "%s\n %s be negative" % [_error("Expecting:"), _colored_value(current)]


static func error_is_not_negative(current) -> String:
	return "%s\n %s be not negative" % [_error("Expecting:"), _colored_value(current)]


static func error_is_zero(current) -> String:
	return "%s\n equal to 0 but is %s" % [_error("Expecting:"), _colored_value(current)]


static func error_is_not_zero() -> String:
	return "%s\n not equal to 0" % [_error("Expecting:")]


static func error_is_wrong_type(current_type :Variant.Type, expected_type :Variant.Type) -> String:
	return "%s\n Expecting type %s but is %s" % [
		_error("Unexpected type comparison:"),
		_colored_value(GdObjects.type_as_string(current_type)),
		_colored_value(GdObjects.type_as_string(expected_type))]


static func error_is_value(operation, current, expected, expected2=null) -> String:
	match operation:
		Comparator.EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting:"), _colored_value(expected), _nerror(current)]
		Comparator.LESS_THAN:
			return "%s\n %s but was '%s'" % [_error("Expecting to be less than:"), _colored_value(expected), _nerror(current)]
		Comparator.LESS_EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting to be less than or equal:"), _colored_value(expected), _nerror(current)]
		Comparator.GREATER_THAN:
			return "%s\n %s but was '%s'" % [_error("Expecting to be greater than:"), _colored_value(expected), _nerror(current)]
		Comparator.GREATER_EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting to be greater than or equal:"), _colored_value(expected), _nerror(current)]
		Comparator.BETWEEN_EQUAL:
			return "%s\n %s\n in range between\n %s <> %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected), _colored_value(expected2)]
		Comparator.NOT_BETWEEN_EQUAL:
			return "%s\n %s\n not in range between\n %s <> %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected), _colored_value(expected2)]
	return "TODO create expected message"


static func error_is_in(current, expected :Array) -> String:
	return "%s\n %s\n is in\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(str(expected))]


static func error_is_not_in(current, expected :Array) -> String:
	return "%s\n %s\n is not in\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(str(expected))]


# - StringAssert ---------------------------------------------------------------------------------
static func error_equal_ignoring_case(current, expected) -> String:
	return "%s\n %s\n but was\n %s (ignoring case)" % [_error("Expecting:"), _colored_value(expected), _colored_value(current)]


static func error_contains(current, expected) -> String:
	return "%s\n %s\n do contains\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_not_contains(current, expected) -> String:
	return "%s\n %s\n not do contain\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_contains_ignoring_case(current, expected) -> String:
	return "%s\n %s\n contains\n %s\n (ignoring case)" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_not_contains_ignoring_case(current, expected) -> String:
	return "%s\n %s\n not do contains\n %s\n (ignoring case)" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_starts_with(current, expected) -> String:
	return "%s\n %s\n to start with\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_ends_with(current, expected) -> String:
	return "%s\n %s\n to end with\n %s" % [_error("Expecting:"), _colored_value(current), _colored_value(expected)]


static func error_has_length(current, expected: int, compare_operator) -> String:
	var current_length = current.length() if current != null else null
	match compare_operator:
		Comparator.EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size:"), _colored_value(expected), _nerror(current_length), _colored_value(current)]
		Comparator.LESS_THAN:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be less than:"), _colored_value(expected), _nerror(current_length), _colored_value(current)]
		Comparator.LESS_EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be less than or equal:"), _colored_value(expected), _nerror(current_length), _colored_value(current)]
		Comparator.GREATER_THAN:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be greater than:"), _colored_value(expected), _nerror(current_length), _colored_value(current)]
		Comparator.GREATER_EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be greater than or equal:"), _colored_value(expected), _nerror(current_length), _colored_value(current)]
	return "TODO create expected message"


# - ArrayAssert specific messgaes ---------------------------------------------------

static func error_arr_contains(current, expected :Array, not_expect :Array, not_found :Array, by_reference :bool) -> String:
	var failure_message = "Expecting contains SAME elements:" if by_reference else "Expecting contains elements:"
	var error := "%s\n %s\n do contains (in any order)\n %s" % [_error(failure_message), _colored_value(current, ", "), _colored_value(expected, ", ")]
	if not not_expect.is_empty():
		error += "\nbut some elements where not expected:\n %s" % _colored_value(not_expect, ", ")
	if not not_found.is_empty():
		var prefix = "but" if not_expect.is_empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _colored_value(not_found, ", ")]
	return error


static func error_arr_contains_exactly(current, expected, not_expect, not_found, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure_message = "Expecting contains exactly elements:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting contains SAME exactly elements:"
	if not_expect.is_empty() and not_found.is_empty():
		var diff := _find_first_diff(current, expected)
		return "%s\n %s\n do contains (in same order)\n %s\n but has different order %s"  % [_error(failure_message), _colored_value(current, ", "), _colored_value(expected, ", "), diff]
	
	var error := "%s\n %s\n do contains (in same order)\n %s" % [_error(failure_message), _colored_value(current, ", "), _colored_value(expected, ", ")]
	if not not_expect.is_empty():
		error += "\nbut some elements where not expected:\n %s" % _colored_value(not_expect, ", ")
	if not not_found.is_empty():
		var prefix = "but" if not_expect.is_empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _colored_value(not_found, ", ")]
	return error


static func error_arr_contains_exactly_in_any_order(current, expected :Array, not_expect :Array, not_found :Array, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure_message = "Expecting contains exactly elements:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting contains SAME exactly elements:"
	var error := "%s\n %s\n do contains exactly (in any order)\n %s" % [_error(failure_message), _colored_value(current, ", "), _colored_value(expected, ", ")]
	if not not_expect.is_empty():
		error += "\nbut some elements where not expected:\n %s" % _colored_value(not_expect, ", ")
	if not not_found.is_empty():
		var prefix = "but" if not_expect.is_empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _colored_value(not_found, ", ")]
	return error


static func error_arr_not_contains(current :Array, expected :Array, found :Array, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure_message = "Expecting:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting SAME:"
	var error := "%s\n %s\n do not contains\n %s" % [_error(failure_message), _colored_value(current, ", "), _colored_value(expected, ", ")]
	if not found.is_empty():
		error += "\n but found elements:\n %s" % _colored_value(found, ", ")
	return error


# - DictionaryAssert specific messages ----------------------------------------------
static func error_contains_keys(current :Array, expected :Array, keys_not_found :Array, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure := "Expecting contains keys:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting contains SAME keys:"
	return "%s\n %s\n to contains:\n %s\n but can't find key's:\n %s" % [_error(failure), _colored_value(current, ", "), _colored_value(expected, ", "), _colored_value(keys_not_found, ", ")]


static func error_not_contains_keys(current :Array, expected :Array, keys_not_found :Array, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure := "Expecting NOT contains keys:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting NOT contains SAME keys"
	return "%s\n %s\n do not contains:\n %s\n but contains key's:\n %s" % [_error(failure), _colored_value(current, ", "), _colored_value(expected, ", "), _colored_value(keys_not_found, ", ")]


static func error_contains_key_value(key, value, current_value, compare_mode :GdObjects.COMPARE_MODE) -> String:
	var failure := "Expecting contains key and value:" if compare_mode == GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST else "Expecting contains SAME key and value:"
	return "%s\n %s : %s\n but contains\n %s : %s" % [_error(failure), _colored_value(key), _colored_value(value), _colored_value(key), _colored_value(current_value)]


# - ResultAssert specific errors ----------------------------------------------------
static func error_result_is_empty(current :Result) -> String:
	return _result_error_message(current, Result.EMPTY)


static func error_result_is_success(current :Result) -> String:
	return _result_error_message(current, Result.SUCCESS)


static func error_result_is_warning(current :Result) -> String:
	return _result_error_message(current, Result.WARN)


static func error_result_is_error(current :Result) -> String:
	return _result_error_message(current, Result.ERROR)


static func error_result_has_message(current :String, expected :String) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting:"), _colored_value(expected), _colored_value(current)]


static func error_result_has_message_on_success(expected :String) -> String:
	return "%s\n %s\n but the Result is a success." % [_error("Expecting:"), _colored_value(expected)]


static func error_result_is_value(current, expected) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting to contain same value:"), _colored_value(expected), _colored_value(current)]


static func _result_error_message(current :Result, expected_type :int) -> String:
	if current == null:
		return _error("Expecting the result must be a %s but was <null>." % result_type(expected_type))
	if current.is_success():
		return _error("Expecting the result must be a %s but was SUCCESS." % result_type(expected_type))
	var error = "Expecting the result must be a %s but was %s:" % [result_type(expected_type), result_type(current._state)]
	return "%s\n %s" % [_error(error), _colored_value(result_message(current))]


static func error_interrupted(func_name :String, expected, elapsed :String) -> String:
	func_name = humanized(func_name)
	if expected == null:
		return "%s %s but timed out after %s" % [_error("Expected:"), func_name, elapsed]
	return "%s %s %s but timed out after %s" % [_error("Expected:"), func_name, _colored_value(expected), elapsed]


static func error_wait_signal(signal_name :String, args :Array, elapsed :String) -> String:
	if args.is_empty():
		return "%s %s but timed out after %s" % [_error("Expecting emit signal:"), _colored_value(signal_name + "()"), elapsed]
	return "%s %s but timed out after %s" % [_error("Expecting emit signal:"), _colored_value(signal_name + "(" + str(args) + ")"), elapsed]


static func error_signal_emitted(signal_name :String, args :Array, elapsed :String) -> String:
	if args.is_empty():
		return "%s %s but is emitted after %s" % [_error("Expecting do not emit signal:"), _colored_value(signal_name + "()"), elapsed]
	return "%s %s but is emitted after %s" % [_error("Expecting do not emit signal:"), _colored_value(signal_name + "(" + str(args) + ")"), elapsed]

static func error_await_signal_on_invalid_instance(source, signal_name :String, args :Array) -> String:
	return "%s\n await_signal_on(%s, %s, %s)" % [_error("Invalid source! Can't await on signal:"), _colored_value(source), signal_name, args]

static func result_type(type :int) -> String:
	match type:
		Result.SUCCESS: return "SUCCESS"
		Result.WARN: return "WARNING"
		Result.ERROR: return "ERROR"
		Result.EMPTY: return "EMPTY"
	return "UNKNOWN"


static func result_message(result :Result) -> String:
	match result._state:
		Result.SUCCESS: return ""
		Result.WARN: return result.warn_message()
		Result.ERROR: return result.error_message()
		Result.EMPTY: return ""
	return "UNKNOWN"
# -----------------------------------------------------------------------------------

# - Spy|Mock specific errors ----------------------------------------------------
static func error_no_more_interactions(summary :Dictionary) -> String:
	var interactions := PackedStringArray()
	for args in summary.keys():
		var times :int = summary[args]
		interactions.append(_format_arguments(args, times))
	return "%s\n%s\n%s" % [_error("Expecting no more interactions!"), _error("But found interactions on:"), "\n".join(interactions)]


static func error_validate_interactions(current_interactions :Dictionary, expected_interactions :Dictionary) -> String:
	var interactions := PackedStringArray()
	for args in current_interactions.keys():
		var times :int = current_interactions[args]
		interactions.append(_format_arguments(args, times))
	var expected_interaction := _format_arguments(expected_interactions.keys()[0], expected_interactions.values()[0])
	return "%s\n%s\n%s\n%s" % [_error("Expecting interaction on:"), expected_interaction, _error("But found interactions on:"), "\n".join(interactions)]


static func _format_arguments(args :Array, times :int) -> String:
	var fname :String = args[0]
	var fargs := args.slice(1) as Array
	var typed_args := _to_typed_args(fargs)
	var fsignature := _colored_value("%s(%s)" % [fname, ", ".join(typed_args)])
	return "	%s	%d time's" % [fsignature, times]


static func _to_typed_args(args :Array) -> PackedStringArray:
	var typed := PackedStringArray()
	for arg in args:
		typed.append(_format_arg(arg) + " :" + GdObjects.type_as_string(typeof(arg)))
	return typed


static func _format_arg(arg) -> String:
	if arg is InputEvent:
		return input_event_as_text(arg)
	return str(arg)


static func _find_first_diff( left :Array, right :Array) -> String:
	for index in left.size():
		var l = left[index]
		var r = "<no entry>" if index >= right.size() else right[index]
		if not GdObjects.equals(l, r):
			return "at position %s\n '%s' vs '%s'" % [_colored_value(index), _typed_value(l), _typed_value(r)]
	return ""


static func error_has_size(current, expected: int) -> String:
	var current_size = null if current == null else current.size()
	return "%s\n %s\n but was\n %s" % [_error("Expecting size:"), _colored_value(expected), _colored_value(current_size)]


static func error_contains_exactly(current: Array, expected: Array) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting exactly equal:"), _colored_value(expected), _colored_value(current)]


static func format_chars(characters :PackedByteArray, type :Color) -> PackedByteArray:
	if characters.size() == 0:# or characters[0] == 10:
		return characters
	var result := PackedByteArray()
	var message := "[bgcolor=#%s][color=with]%s[/color][/bgcolor]" % [type.to_html(), characters.get_string_from_utf8().replace("\n", "<LF>")]
	result.append_array(message.to_utf8_buffer())
	return result


static func format_invalid(value :String) -> String:
	return "[bgcolor=#%s][color=with]%s[/color][/bgcolor]" % [SUB_COLOR.to_html(), value]


static func humanized(value :String) -> String:
	return value.replace("_", " ")
