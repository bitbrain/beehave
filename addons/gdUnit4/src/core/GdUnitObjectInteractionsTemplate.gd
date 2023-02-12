class_name GdUnitObjectInteractionsTemplate

var __expected_interactions :int = -1
var __expect_result :int
var __saved_interactions := Dictionary()
var __verified_interactions := Array()
var __caller :Object

func __save_function_interaction(args :Array) -> void:
	var matcher := GdUnitArgumentMatchers.to_matcher(args, true)
	for key in __saved_interactions.keys():
		if matcher.is_match(key):
			__saved_interactions[key] += 1
			return
	__saved_interactions[args] = 1

func __is_verify_interactions() -> bool:
	return __expected_interactions != -1

func __do_verify_interactions(times :int = 1, expect_result :int = GdUnitAssert.EXPECT_SUCCESS) -> Object:
	__expected_interactions = times
	__expect_result = expect_result
	return self

func __verify_interactions(args :Array):
	var summary := Dictionary()
	var total_interactions := 0
	var matcher := GdUnitArgumentMatchers.to_matcher(args, true)
	for key in __saved_interactions.keys():
		if matcher.is_match(key):
			var interactions :int = __saved_interactions.get(key, 0)
			total_interactions += interactions
			summary[key] = interactions
			# add as verified
			__verified_interactions.append(key)
	
	var gd_assert := GdUnitAssertImpl.new(__caller, "", __expect_result)
	if total_interactions != __expected_interactions:
		var expected_summary = {args : __expected_interactions}
		var error_message :String
		# if no interactions macht collect not verified interactions for failure report
		if summary.is_empty():
			var current_summary = __verify_no_more_interactions()
			error_message = GdAssertMessages.error_validate_interactions(current_summary, expected_summary)
		else:
			error_message = GdAssertMessages.error_validate_interactions(summary, expected_summary)
		gd_assert.report_error(error_message)
	else:
		gd_assert.report_success()
	__expected_interactions = -1

func __verify_no_interactions() -> Dictionary:
	var summary := Dictionary()
	if not __saved_interactions.is_empty():
		for func_call in __saved_interactions.keys():
			summary[func_call] = __saved_interactions[func_call]
	return summary

func __verify_no_more_interactions() -> Dictionary:
	var summary := Dictionary()
	var called_functions :Array = __saved_interactions.keys()
	if called_functions != __verified_interactions:
		# collect the not verified functions
		var called_but_not_verified := called_functions.duplicate()
		for verified_function in __verified_interactions:
			called_but_not_verified.erase(verified_function)
		
		for not_verified in called_but_not_verified:
			summary[not_verified] = __saved_interactions[not_verified]
	return summary

func __reset_interactions() -> void:
	__saved_interactions.clear()

func __filter_vargs(arg_values :Array) -> Array:
	var filtered := Array()
	for arg in arg_values:
		if typeof(arg) == TYPE_STRING and arg == GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE:
			continue
		filtered.append(arg)
	return filtered

func __set_caller(caller :Object) -> void:
	__caller = caller
