## Base interface of all GdUnit asserts
class_name GdUnitAssert
extends RefCounted


# Scans the current stack trace for the root cause to extract the line number
static func _get_line_number() -> int:
	var stack_trace := get_stack()
	if stack_trace == null or stack_trace.is_empty():
		return -1
	for stack_info in stack_trace:
		var function :String = stack_info.get("function")
		# we catch helper asserts to skip over to return the correct line number
		if function.begins_with("assert_"):
			continue
		if function.begins_with("test_"):
			return stack_info.get("line")
		var source :String = stack_info.get("source")
		if source.is_empty() \
			or source.begins_with("user://") \
			or source.ends_with("GdUnitAssert.gd") \
			or source.ends_with("AssertImpl.gd") \
			or source.ends_with("GdUnitTestSuite.gd") \
			or source.ends_with("GdUnitSceneRunnerImpl.gd") \
			or source.ends_with("GdUnitObjectInteractions.gd") \
			or source.ends_with("GdUnitAwaiter.gd"):
			continue
		return stack_info.get("line")
	return -1


## Verifies that the current value is null.
func is_null():
	return self


## Verifies that the current value is not null.
func is_not_null():
	return self


## Verifies that the current value is equal to expected one.
@warning_ignore("unused_parameter")
func is_equal(expected):
	return self


## Verifies that the current value is not equal to expected one.
@warning_ignore("unused_parameter")
func is_not_equal(expected):
	return self


func test_fail():
	return self


## Overrides the default failure message by given custom message.
@warning_ignore("unused_parameter")
func override_failure_message(message :String):
	return self
