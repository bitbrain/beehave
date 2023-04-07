class_name GdUnitArrayAssertImpl
extends GdUnitArrayAssert

var _base :GdUnitAssert

func _init(current, expect_result: int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if not __validate_value_type(current):
		report_error("GdUnitArrayAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))


func __validate_value_type(value) -> bool:
	return (
		value is ValueProvider
		or value == null
		or GdObjects.is_array_type(value)
	)


func __current() -> Variant:
	var current = _base.__current()
	if current == null or typeof(current) == TYPE_ARRAY:
		return current
	return Array(current)


func __expected(expected) -> Variant:
	if typeof(expected) == TYPE_ARRAY:
		return expected
	return Array(expected)


func _array_equals_div(current :Array, expected :Array, case_sensitive :bool = false) -> Array:
	var current_ := PackedStringArray(current)
	var expected_ := PackedStringArray(expected)
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
	
	for index in range(current.size(), expected.size()):
		var value := expected_[index]
		expected_[index] = GdAssertMessages.format_invalid(value)
		index_report_.push_back({"index" : index, "current" : "<N/A>", "expected": value})
	return [current_, expected_, index_report_]


func _array_div(left :Array, right :Array, _same_order := false) -> Array:
	var not_expect := left.duplicate(true)
	var not_found := right.duplicate(true)
	for index_c in left.size():
		var c = left[index_c]
		for index_e in right.size():
			var e = right[index_e]
			if GdObjects.equals(c, e):
				GdObjects.array_erase_value(not_expect, e)
				GdObjects.array_erase_value(not_found, c)
				break
	return [not_expect, not_found]


func report_success() -> GdUnitArrayAssert:
	_base.report_success()
	return self


func report_error(error :String) -> GdUnitArrayAssert:
	_base.report_error(error)
	return self


# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitArrayAssert:
	# normalize text to get rid of windows vs unix line formatting
	_base.has_failure_message(expected)
	return self


func starts_with_failure_message(expected: String) -> GdUnitArrayAssert:
	_base.starts_with_failure_message(expected)
	return self


func override_failure_message(message :String) -> GdUnitArrayAssert:
	_base.override_failure_message(message)
	return self


func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------


func is_null() -> GdUnitArrayAssert:
	_base.is_null()
	return self


func is_not_null() -> GdUnitArrayAssert:
	_base.is_not_null()
	return self


# Verifies that the current String is equal to the given one.
func is_equal(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if current_ == null and expected_ != null:
		return report_error(GdAssertMessages.error_equal(null, GdObjects.array_to_string(expected_, ", ", 32)))
	if not GdObjects.equals(current_, expected_):
		var diff := _array_equals_div(current_, expected_)
		var expected_as_list := GdObjects.array_to_string(diff[0], ", ", 32)
		var current_as_list := GdObjects.array_to_string(diff[1], ", ", 32)
		var index_report = diff[2]
		return report_error(GdAssertMessages.error_equal(expected_as_list, current_as_list, index_report))
	return report_success()


# Verifies that the current Array is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if current_ == null and expected_ != null:
		return report_error(GdAssertMessages.error_equal(null, GdObjects.array_to_string(expected_, ", ", 32)))
	if not GdObjects.equals(current_, expected_, true):
		var diff := _array_equals_div(current_, expected_, true)
		var expected_as_list := GdObjects.array_to_string(diff[0], ", ", 32)
		var current_as_list := GdObjects.array_to_string(diff[1], ", ", 32)
		var index_report = diff[2]
		return report_error(GdAssertMessages.error_equal(expected_as_list, current_as_list, index_report))
	return report_success()


func is_not_equal(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if GdObjects.equals(current_, expected_):
		var c := GdObjects.array_to_string(current_, ", ", 32)
		var e := GdObjects.array_to_string(expected_, ", ", 32)
		return report_error(GdAssertMessages.error_not_equal(c, e))
	return report_success()


func is_not_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if GdObjects.equals(current_, expected_, true):
		var c := GdObjects.array_to_string(current_, ", ", 32)
		var e := GdObjects.array_to_string(expected_, ", ", 32)
		return report_error(GdAssertMessages.error_not_equal_case_insensetiv(c, e))
	return report_success()


# Verifies that the current Array is empty, it has a size of 0.
func is_empty() -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ == null or current_.size() > 0:
		return report_error(GdAssertMessages.error_is_empty(current_))
	return report_success()


# Verifies that the current Array is not empty, it has a size of minimum 1.
func is_not_empty() -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ != null and current_.size() == 0:
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()


# Verifies that the current Array has a size of given value.
func has_size(expected: int) -> GdUnitArrayAssert:
	var current_ = __current()
	if current_ == null or current_.size() != expected:
		return report_error(GdAssertMessages.error_has_size(current_, expected))
	return report_success()


# Verifies that the current Array contains the given values, in any order.
func contains(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains(current_, expected_, [], expected_))
	var diffs := _array_div(current_, expected_)
	#var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	if not not_found.is_empty():
		return report_error(GdAssertMessages.error_arr_contains(current_, expected_, [], not_found))
	return report_success()


# Verifies that the current Array contains only the given values and nothing else, in order.
func contains_exactly(expected :Array) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected_, [], expected_))
	# has same content in same order
	if GdObjects.equals(current_, expected_):
		return report_success()
	# check has same elements but in different order
	if GdObjects.equals_sorted(current_, expected_):
		return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected_, [], []))
	# find the difference
	var diffs := _array_div(current_, expected_, true)
	var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected_, not_expect, not_found))


# Verifies that the current Array contains exactly only the given values and nothing else, in any order.
func contains_exactly_in_any_order(expected) -> GdUnitArrayAssert:
	var current_ = __current()
	var expected_ = __expected(expected)
	if current_ == null:
		return report_error(GdAssertMessages.error_arr_contains_exactly_in_any_order(current_, expected_, [], expected_))
	# find the difference
	var diffs := _array_div(current_, expected_, false)
	var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	if not_expect.is_empty() and not_found.is_empty():
		return report_success()
	return report_error(GdAssertMessages.error_arr_contains_exactly_in_any_order(current_, expected_, not_expect, not_found))


@warning_ignore("shadowed_global_identifier")
func is_same(expected) -> GdUnitAssert:
	_base.is_same(expected)
	return self


func is_not_same(expected) -> GdUnitAssert:
	_base.is_not_same(expected)
	return self


func is_instanceof(expected) -> GdUnitAssert:
	_base.is_instanceof(expected)
	return self


# extracts all values by given function name or null if not exists
func extract(func_name :String, args := Array()) -> GdUnitArrayAssert:
	var extracted_elements := Array()
	var extractor := GdUnitFuncValueExtractor.new(func_name, args)
	var current = __current()
	if current == null:
		extracted_elements.append(null)
	else:
		for element in current:
			extracted_elements.append(extractor.extract_value(element))
	_base._current_value_provider = DefaultValueProvider.new(extracted_elements)
	return self


# Extracts all values by given extractors into a new ArrayAssert
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
	var extractors := GdObjects.array_filter_value([extr0, extr1, extr2, extr3, extr4, extr5, extr6, extr7, extr8, extr9], null)
	var extracted_elements := Array()
	var current = __current()
	if current == null:
		extracted_elements.append(null)
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
	_base._current_value_provider = DefaultValueProvider.new(extracted_elements)
	return self
