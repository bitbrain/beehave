# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitSpyImpl

var __instance_delegator

# self reference holder, use this kind of hack to store static function calls 
# it is important to manually free by '__release_double' otherwise it ends up in orphan instance
const __store := [{}]

static func __instance():
	var key = "instance"
	return __store[0][key]

func __set_singleton(delegator):
	# store self need to mock static functions
	var key = "instance"
	__store[0][key] = self
	__instance_delegator = delegator
	#assert(__self[0] != null, "Invalid mock")

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	__store.clear()
	__instance_delegator = null

