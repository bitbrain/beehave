class_name GdUnitArrayAssertImpl
extends GdUnitArrayAssert

var _base :GdUnitAssert
var _current_value_provider :ValueProvider


func _init(current):
	_current_value_provider = DefaultValueProvider.new(current)
	_base = GdUnitAssertImpl.new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)
	if not __validate_value_type(current):
		report_error("GdUnitArrayAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func report_success() -> GdUnitArrayAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitArrayAssert:
	_base.report_error(error)
	return self

func _failure_message() -> String:
	return _base._current_error_message


func override_failure_message(message :String) -> GdUnitArrayAssert:
	_base.override_failure_message(message)
	return self


func __validate_value_type(value) -> bool:
	return (
		value == null
		or GdArrayTools.is_array_type(value)
	)


func __current() -> Variant:
	return _current_value_provider.get_value()


func _array_equals_div(current, expected, case_sensitive :bool = false) -> Array:
	var current_ := PackedStringArray(Array(current))
	var expected_ := PackedStringArray(Array(expected))
	var index_report_ := Array()
	for index in current_.size():
		var c := current_[index]
		if index < expected_.size():
			var e := expected_[index]
			if not GdObjects.equals(c, e, case_sensitive):
				var length := GdUnitTools.max_length(c, e)
				current_[index] = GdAssertMessages.format_invalid(c.lpad(length))
				expected_[index] = e.lpad(length)
				index_report_.push_back({"index" : index, "current" :c, "expected": e})
		else:
			current_[index] = GdAssertMessages.format_invalid(c)
			index_report_.push_back({"index" : index, "current" :c, "expected": "<N/A>"})
	
	for index in range(current.size(), expected_.size()):
		var value := expected_[index]
		expected_[index] = GdAssertMessages.format_invalid(value)
		index_report_.push_back({"index" : index, "current" : "<N/A>", "expected": value})
	return [current_, expected_, index_report_]


func _array_div(compare_mode :GdObjects.COMPARE_MODE, left :Array[Variant], right :Array[Variant], _same_order := false) -> Array[Variant]:
	var not_expect := left.duplicate(true)
	var not_found := right.duplicate(true)
	for index_c in left.size():
		var c = left[index_c]
		for index_e in right.size():
			var e = right[index_e]
			if GdObjects.equals(c, e, false, compare_mode):
				GdArrayTools.erase_value(not_expect, e)
				GdArrayTools.erase_value(not_found, c)
				break
	return [not_expect, not_found]



func _contains(expected, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var by_reference := compare_mode == GdObjects.COMPARE_MODE.OBJECT_REFERENCE
	var current_ = __current()
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains(current_, expected, [], expected, by_reference))
	var diffs := _array_div(compare_mode, current_, expected)
	#var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	if not not_found.is_empty():
		return report_error(GdAssertMessages.error_arr_contains(current_, expected, [], not_found, by_reference))
	return report_success()


func _contains_exactly(expected, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected, [], expected, compare_mode))
	# has same content in same order
	if GdObjects.equals(Array(current_), Array(expected), false, compare_mode):
		return report_success()
	# check has same elements but in different order
	if GdObjects.equals_sorted(Array(current_), Array(expected), false, compare_mode):
		return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected, [], [], compare_mode))
	# find the difference
	var diffs := _array_div(compare_mode, current_, expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)
	var not_expect := diffs[0] as Array[Variant]
	var not_found := diffs[1] as Array[Variant]
	return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected, not_expect, not_found, compare_mode))


func _contains_exactly_in_any_order(expected, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains_exactly_in_any_order(current_, expected, [], expected, compare_mode))
	# find the difference
	var diffs := _array_div(compare_mode, current_, expected, false)
	var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	if not_expect.is_empty() and not_found.is_empty():
		return report_success()
	return report_error(GdAssertMessages.error_arr_contains_exactly_in_any_order(current_, expected, not_expect, not_found, compare_mode))


func _not_contains(expected, compare_mode :GdObjects.COMPARE_MODE) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains_exactly_in_any_order(current_, expected, [], expected, compare_mode))
	var diffs := _array_div(compare_mode, current_, expected)
	var found := diffs[0] as Array
	if found.size() == current_.size():
		return report_success()
	var diffs2 := _array_div(compare_mode, expected, diffs[1])
	return report_error(GdAssertMessages.error_arr_not_contains(current_, expected, diffs2[0], compare_mode))


func is_null() -> GdUnitArrayAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitArrayAssert:
	_base.is_not_null()
	return self


# Verifies that the current String is equal to the given one.
func is_equal(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if current_ == null and expected != null:
		return report_error(GdAssertMessages.error_equal(null, expected))
	if not GdObjects.equals(current_, expected):
		var diff := _array_equals_div(current_, expected)
		var expected_as_list = GdArrayTools.as_string(diff[0], false)
		var current_as_list = GdArrayTools.as_string(diff[1], false)
		var index_report = diff[2]
		return report_error(GdAssertMessages.error_equal(expected_as_list, current_as_list, index_report))
	return report_success()


# Verifies that the current Array is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if current_ == null and expected != null:
		return report_error(GdAssertMessages.error_equal(null, GdArrayTools.as_string(expected)))
	if not GdObjects.equals(current_, expected, true):
		var diff := _array_equals_div(current_, expected, true)
		var expected_as_list := GdArrayTools.as_string(diff[0])
		var current_as_list := GdArrayTools.as_string(diff[1])
		var index_report = diff[2]
		return report_error(GdAssertMessages.error_equal(expected_as_list, current_as_list, index_report))
	return report_success()


func is_not_equal(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if GdObjects.equals(current_, expected):
		return report_error(GdAssertMessages.error_not_equal(current_, expected))
	return report_success()


func is_not_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current_ = __current()
	if GdObjects.equals(current_, expected, true):
		var c := GdArrayTools.as_string(current_)
		var e := GdArrayTools.as_string(expected)
		return report_error(GdAssertMessages.error_not_equal_case_insensetiv(c, e))
	return report_success()


func is_empty() -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ == null or current_.size() > 0:
		return report_error(GdAssertMessages.error_is_empty(current_))
	return report_success()


func is_not_empty() -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ != null and current_.size() == 0:
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()


@warning_ignore("unused_parameter", "shadowed_global_identifier")
func is_same(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current = __current()
	if not is_same(current, expected):
		report_error(GdAssertMessages.error_is_same(current, expected))
	return self


func is_not_same(expected) -> GdUnitArrayAssert:
	if not __validate_value_type(expected):
		return report_error("ERROR: expected value: <%s>\n is not a Array Type!" % GdObjects.typeof_as_string(expected))
	var current = __current()
	if is_same(current, expected):
		report_error(GdAssertMessages.error_not_same(current, expected))
	return self


func has_size(expected: int) -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ == null or current_.size() != expected:
		return report_error(GdAssertMessages.error_has_size(current_, expected))
	return report_success()


func contains(expected) -> GdUnitArrayAssert:
	return _contains(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func contains_exactly(expected) -> GdUnitArrayAssert:
	return _contains_exactly(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func contains_exactly_in_any_order(expected) -> GdUnitArrayAssert:
	return _contains_exactly_in_any_order(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func contains_same(expected) -> GdUnitArrayAssert:
	return _contains(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func contains_same_exactly(expected) -> GdUnitArrayAssert:
	return _contains_exactly(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func contains_same_exactly_in_any_order(expected) -> GdUnitArrayAssert:
	return _contains_exactly_in_any_order(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func not_contains(expected) -> GdUnitArrayAssert:
	return _not_contains(expected, GdObjects.COMPARE_MODE.PARAMETER_DEEP_TEST)


func not_contains_same(expected) -> GdUnitArrayAssert:
	return _not_contains(expected, GdObjects.COMPARE_MODE.OBJECT_REFERENCE)


func is_instanceof(expected) -> GdUnitAssert:
	_base.is_instanceof(expected)
	return self


func extract(func_name :String, args := Array()) -> GdUnitArrayAssert:
	var extracted_elements := Array()
	var extractor := GdUnitFuncValueExtractor.new(func_name, args)
	var current = __current()
	if current == null:
		_current_value_provider = DefaultValueProvider.new(null)
	else:
		for element in current:
			extracted_elements.append(extractor.extract_value(element))
		_current_value_provider = DefaultValueProvider.new(extracted_elements)
	return self


func extractv(
	extr0 :GdUnitValueExtractor, 
	extr1 :GdUnitValueExtractor = null, 
	extr2 :GdUnitValueExtractor = null,
	extr3 :GdUnitValueExtractor = null,
	extr4 :GdUnitValueExtractor = null,
	extr5 :GdUnitValueExtractor = null,
	extr6 :GdUnitValueExtractor = null,
	extr7 :GdUnitValueExtractor = null,
	extr8 :GdUnitValueExtractor = null,
	extr9 :GdUnitValueExtractor = null) -> GdUnitArrayAssert:
	var extractors :Variant = GdArrayTools.filter_value([extr0, extr1, extr2, extr3, extr4, extr5, extr6, extr7, extr8, extr9], null)
	var extracted_elements := Array()
	var current = __current()
	if current == null:
		_current_value_provider = DefaultValueProvider.new(null)
	else:
		for element in __current():
			var ev :Array[Variant] = [GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG, GdUnitTuple.NO_ARG]
			for index in extractors.size():
				var extractor :GdUnitValueExtractor = extractors[index]
				ev[index] = extractor.extract_value(element)
			
			if extractors.size() > 1:
				extracted_elements.append(GdUnitTuple.new(ev[0], ev[1], ev[2], ev[3], ev[4], ev[5], ev[6], ev[7], ev[8], ev[9]))
			else:
				extracted_elements.append(ev[0])
		_current_value_provider = DefaultValueProvider.new(extracted_elements)
	return self
