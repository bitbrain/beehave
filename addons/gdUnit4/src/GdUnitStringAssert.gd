# An Assertion Tool to verify String values
class_name GdUnitStringAssert
extends GdUnitAssert

# Verifies that the current String is equal to the given one.
func is_equal(expected) -> GdUnitStringAssert:
	return self

# Verifies that the current String is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitStringAssert:
	return self

# Verifies that the current String is not equal to the given one.
func is_not_equal(expected) -> GdUnitStringAssert:
	return self

# Verifies that the current String is not equal to the given one, ignoring case considerations.
func is_not_equal_ignoring_case(expected) -> GdUnitStringAssert:
	return self

# Verifies that the current String is empty, it has a length of 0.
func is_empty() -> GdUnitStringAssert:
	return self

# Verifies that the current String is not empty, it has a length of minimum 1.
func is_not_empty() -> GdUnitStringAssert:
	return self

# Verifies that the current String contains the given String.
func contains(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String does not contain the given String.
func not_contains(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String does not contain the given String, ignoring case considerations.
func contains_ignoring_case(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String does not contain the given String, ignoring case considerations.
func not_contains_ignoring_case(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String starts with the given prefix.
func starts_with(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String ends with the given suffix.
func ends_with(expected: String) -> GdUnitStringAssert:
	return self

# Verifies that the current String has the expected length by used comparator.
func has_length(lenght: int, comparator: int = Comparator.EQUAL) -> GdUnitStringAssert:
	return self
