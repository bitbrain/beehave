class_name RPCMessage
extends RPC

var _message :String

static func of(message :String) -> RPCMessage:
	var rpc = RPCMessage.new()
	rpc._message = message
	return rpc

func message() -> String:
	return _message

func to_string():
	return "RPCMessage: " + _message
