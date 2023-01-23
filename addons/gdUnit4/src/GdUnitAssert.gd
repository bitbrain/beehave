# Base interface of all GdUnit asserts
class_name GdUnitAssert
extends RefCounted

# assert expects ends with success
const EXPECT_SUCCESS:int = 0
# assert expects ends with error
const EXPECT_FAIL:int    = 1


# Verifies that the current value is null.
func is_null():
	return self

# Verifies that the current value is not null.
func is_not_null():
	return self

# Verifies that the current value is equal to expected one.
func is_equal(expected):
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected):
	return self

func test_fail():
	return self

# Verifies the failure message is equal to expected one.
func has_failure_message(expected: String):
	return self

# Verifies that the failure starts with the given prefix.
func starts_with_failure_message(expected: String):
	return self

# Overrides the default failure message by given custom message.
func override_failure_message(message :String):
	return self
