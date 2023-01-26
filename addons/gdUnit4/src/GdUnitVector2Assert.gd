class_name GdUnitVector2Assert
extends GdUnitAssert

# Verifies that the current value is equal to expected one.
func is_equal(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current and expected value are approximately equal.
func is_equal_approx(expected :Vector2, approx :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is less than the given one.
func is_less(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is less than or equal the given one.
func is_less_equal(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is greater than the given one.
func is_greater(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is greater than or equal the given one.
func is_greater_equal(expected :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is between the given boundaries (inclusive).
func is_between(from :Vector2, to :Vector2) -> GdUnitVector2Assert:
	return self

# Verifies that the current value is not between the given boundaries (inclusive).
func is_not_between(from :Vector2, to :Vector2) -> GdUnitVector2Assert:
	return self
