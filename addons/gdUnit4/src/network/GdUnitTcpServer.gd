@tool
class_name GdUnitTcpServer
extends Node

signal client_connected(client_id)
signal client_disconnected(client_id)
signal rpc_data(rpc_data)

var _server :TCPServer

class TcpConnection extends Node:
	var _id :int
	var _stream : StreamPeerTCP
	
	func _init(server :TCPServer):
		_stream = server.take_connection()
		_stream.set_big_endian(true)
		_id = _stream.get_instance_id()
		rpc_send(RPCClientConnect.new().with_id(_id))
	
	func _ready():
		get_parent().emit_signal("client_connected", _id)
	
	func close() -> void:
		rpc_send(RPCClientDisconnect.new().with_id(_id))
		get_parent().emit_signal("client_disconnected", _id)
		_stream.disconnect_from_host()
	
	func id() -> int:
		return _id
	
	func rpc_send(rpc :RPC) -> void:
		_stream.put_var(rpc.serialize(), true)
	
	func _process(_delta):
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			return null
		var available_bytes := _stream.get_available_bytes()
		if available_bytes > 0:
			var data := _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				push_error("Error getting data from stream: %s " % data[0])
				return
			else:
				var data_package :PackedByteArray = data[1]
				var json_array := data_package.get_string_from_ascii().split(GdUnitServerConstants.JSON_RESPONSE_DELIMITER)
				for json in json_array:
					# ignore empty jsons
					if json.is_empty():
						continue
					var rpc = RPC.deserialize(json)
					if rpc is RPCClientDisconnect:
						close()
					get_parent().emit_signal("rpc_data", rpc)
	
	func console(message :String) -> void:
		#print_debug("TCP Connection:", message)
		pass

func _ready():
	_server = TCPServer.new()
	connect("client_connected", Callable(self, "_on_client_connected"))
	connect("client_disconnected", Callable(self, "_on_client_disconnected"))

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()

func start() -> Result:
	var server_port := GdUnitServerConstants.GD_TEST_SERVER_PORT
	var err := OK
	for retry in GdUnitServerConstants.DEFAULT_SERVER_START_RETRY_TIMES:
		err = _server.listen(server_port, "127.0.0.1")
		if err != OK:
			prints("GdUnit3: Can't establish server checked port %d, error code: %s" % [server_port, err])
			server_port += 1
			prints("GdUnit3: Retry (%d) ..." % retry)
		else:
			break
	if err != OK:
		if err == ERR_ALREADY_IN_USE:
			return Result.error("GdUnit3: Can't establish server, error code: %s, The server is already in use" % err)
		return Result.error("GdUnit3: Can't establish server, error code: %s" % err)
	prints("GdUnit3: Server successfully started checked port %d" % server_port)
	return Result.success(server_port)

func stop() -> void:
	_server.stop()
	for connection in get_children():
		if connection is TcpConnection:
			connection.close()
			remove_child(connection)

func disconnect_client(client_id :int) -> void:
	for connection in get_children():
		if connection is TcpConnection and connection.id() == client_id:
			connection.close()

func _process(_delta):
	if not _server.is_listening():
		return
	
	# check is new connection incomming
	if _server.is_connection_available():
		add_child(TcpConnection.new(_server))

func _on_client_connected(client_id :int):
	console("client connected %d" % client_id)

func _on_client_disconnected(client_id :int):
	console("client disconnected %d" % client_id)
	for connection in get_children():
		if connection is TcpConnection and connection.id() == client_id:
			remove_child(connection)
	
func console(message :String) -> void:
	#print_debug("TCP Server:", message)
	pass
