# An Assertion Tool to verify for emitted signals until a waiting time
class_name GdUnitSignalAssert
extends GdUnitAssert

# Verifies that given signal is emitted until waiting time
func is_emitted(name :String, args := []) -> GdUnitSignalAssert:
	return self

# Verifies that given signal is NOT emitted until waiting time
func is_not_emitted(name :String, args := []) -> GdUnitSignalAssert:
	return self

# Verifies the signal exists checked the emitter
func is_signal_exists(name :String) -> GdUnitSignalAssert:
	return self

# Verifies the failure message is equal to expected one.
func has_failure_message(expected: String) -> GdUnitSignalAssert:
	return self

# Verifies that the failure starts with the given prefix.
func starts_with_failure_message(expected: String) -> GdUnitSignalAssert:
	return self

# Overrides the default failure message by given custom message.
func override_failure_message(message :String) -> GdUnitSignalAssert:
	return self

# Sets the assert signal timeout in ms, if the time over a failure is reported
# e.g.
# do wait until 5s the instance has emitted the signal `signal_a`
# assert_signal(instance).wait_until(5000).is_emitted("signal_a")
func wait_until(timeout :int) -> GdUnitSignalAssert:
	return self
