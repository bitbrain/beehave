# An Assertion Tool to verify boolean values
class_name GdUnitBoolAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitBoolAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitBoolAssert:
	return self

# Verifies that the current value is equal to the given one.
func is_equal(expected) -> GdUnitBoolAssert:
	return self

# Verifies that the current value is not equal to the given one.
func is_not_equal(expected) -> GdUnitBoolAssert:
	return self

# Verifies that the current value is true.
func is_true() -> GdUnitBoolAssert:
	return self

# Verifies that the current value is false.
func is_false() -> GdUnitBoolAssert:
	return self

func override_failure_message(message :String) -> GdUnitBoolAssert:
	return self
