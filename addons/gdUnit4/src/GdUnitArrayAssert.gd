# An Assertion Tool to verify array values
class_name GdUnitArrayAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitArrayAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is equal to the given one.
func is_equal(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not equal to the given one.
func is_not_equal(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not equal to the given one, ignoring case considerations.
func is_not_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is empty, it has a size of 0.
func is_empty() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not empty, it has a size of minimum 1.
func is_not_empty() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array has a size of given value.
func has_size(expectd: int) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array contains the given values, in any order.
func contains(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array contains exactly only the given values and nothing else, in same order.
func contains_exactly(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array contains exactly only the given values and nothing else, in any order.
func contains_exactly_in_any_order(expected) -> GdUnitArrayAssert:
	return self

# Extracts all values by given function name and optional arguments into a new ArrayAssert
# If the elements not accessible by `func_name` the value is converted to `"n.a"`, expecting null values
func extract(func_name: String, args := Array()) -> GdUnitArrayAssert:
	return self

# Extracts all values by given extractor's into a new ArrayAssert
# If the elements not extractable than the value is converted to `"n.a"`, expecting null values
func extractv(
	extractor0 :GdUnitValueExtractor,
	extractor1 :GdUnitValueExtractor = null,
	extractor2 :GdUnitValueExtractor = null,
	extractor3 :GdUnitValueExtractor = null,
	extractor4 :GdUnitValueExtractor = null,
	extractor5 :GdUnitValueExtractor = null,
	extractor6 :GdUnitValueExtractor = null,
	extractor7 :GdUnitValueExtractor = null,
	extractor8 :GdUnitValueExtractor = null,
	extractor9 :GdUnitValueExtractor = null) -> GdUnitArrayAssert:
	return self
