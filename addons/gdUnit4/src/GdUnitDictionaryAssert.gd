# An Assertion Tool to verify dictionary
class_name GdUnitDictionaryAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitDictionaryAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary is equal to the given one, ignoring order.
func is_equal(expected) -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary is not equal to the given one, ignoring order.
func is_not_equal(expected) -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary is empty, it has a size of 0.
func is_empty() -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary is not empty, it has a size of minimum 1.
func is_not_empty() -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary has a size of given value.
func has_size(expected: int) -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary contains the given key(s).
func contains_keys(expected :Array) -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary not contains the given key(s).
func contains_not_keys(expected :Array) -> GdUnitDictionaryAssert:
	return self

# Verifies that the current dictionary contains the given key and value.
func contains_key_value(key, value) -> GdUnitDictionaryAssert:
	return self
