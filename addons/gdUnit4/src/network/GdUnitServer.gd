@tool
extends Node

@onready var _server :GdUnitTcpServer = $TcpServer

# holds tasks to execute by key = task_name and value = GdUnitTask
var _tasks := Dictionary() 

func _ready():
	var result := _server.start()
	if result.is_error():
		push_error(result.error_message())
		return
	var server_port :int = result.value()
	Engine.set_meta("gdunit_server_port", server_port)
	_server.connect("client_connected", Callable(self, "_on_client_connected"))
	_server.connect("client_disconnected", Callable(self, "_on_client_disconnected"))
	_server.connect("rpc_data", Callable(self, "_receive_rpc_data"))

func _on_client_connected(client_id :int) -> void:
	GdUnitSignals.instance().gdunit_client_connected.emit(client_id)

func _on_client_disconnected(client_id :int) -> void:
	GdUnitSignals.instance().gdunit_client_disconnected.emit(client_id)

func _on_gdunit_runner_stop(client_id :int):
	if _server:
		_server.disconnect_client(client_id)

func _receive_rpc_data(rpc :RPC) -> void:
	if rpc is RPCMessage:
		GdUnitSignals.instance().gdunit_message.emit(rpc.message())
		return
	if rpc is RPCGdUnitEvent:
		GdUnitSignals.instance().gdunit_event.emit(rpc.event())
		return
	if rpc is RPCGdUnitTestSuite:
		GdUnitSignals.instance().gdunit_add_test_suite.emit(rpc.dto())
