# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitSpyImpl

var __instance_delegator


static func __instance():
	return GdUnitStaticDictionary.get_value("spy_instance")


func __set_singleton(delegator):
	# store self need to mock static functions
	GdUnitStaticDictionary.add_value("spy_instance", self)
	__instance_delegator = delegator
	#assert(__self[0] != null, "Invalid mock")


func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	GdUnitStaticDictionary.erase("spy_instance")
	__instance_delegator = null

