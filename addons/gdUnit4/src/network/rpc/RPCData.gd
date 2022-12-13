class_name RPCData
extends RPC

var _value

func with_data(value) -> RPCData:
	_value = value
	return self

func data() :
	return _value
