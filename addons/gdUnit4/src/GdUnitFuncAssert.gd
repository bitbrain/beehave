# An Assertion Tool to verify function callback values
class_name GdUnitFuncAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitAssert:
	return self

# Verifies that the current value is equal to the given one.
func is_equal(expected) -> GdUnitAssert:
	return self

# Verifies that the current value is not equal to the given one.
func is_not_equal(expected) -> GdUnitAssert:
	return self

# Verifies that the current value is true.
func is_true() -> GdUnitAssert:
	return self

# Verifies that the current value is false.
func is_false() -> GdUnitAssert:
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

# Sets the timeout in ms to wait the function returnd the expected value, if the time over a failure is emitted
# e.g.
# do wait until 5s the function `is_state` is returns 10 
# assert_func(instance, "is_state").wait_until(5000).is_equal(10)
func wait_until(timeout :int) -> GdUnitAssert:
	return self
