## A tuple implementation to hold two or many values 
class_name GdUnitTuple
extends RefCounted

const NO_ARG :Variant = GdUnitConstants.NO_ARG

var __values :Array = Array()


func _init(arg0,arg1,arg2=NO_ARG,arg3=NO_ARG,arg4=NO_ARG,arg5=NO_ARG,arg6=NO_ARG,arg7=NO_ARG,arg8=NO_ARG,arg9=NO_ARG):
	__values = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)


func values() -> Array:
	return __values


func _to_string():
	return "tuple(%s)" % str(__values)
