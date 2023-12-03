@tool
class_name GdUnitTcpServer
extends Node

signal client_connected(client_id)
signal client_disconnected(client_id)
signal rpc_data(rpc_data)

var _server :TCPServer


class TcpConnection extends Node:
	var _id :int
	var _stream
	var _readBuffer :String = ""
	
	
	func _init(p_server):
		#assert(p_server is TCPServer)
		_stream = p_server.take_connection()
		_stream.set_big_endian(true)
		_id = _stream.get_instance_id()
		rpc_send(RPCClientConnect.new().with_id(_id))
	
	
	func _ready():
		server().client_connected.emit(_id)
	
	
	func close() -> void:
		rpc_send(RPCClientDisconnect.new().with_id(_id))
		server().client_disconnected.emit(_id)
		_stream.disconnect_from_host()
		_readBuffer = ""
	
	
	func id() -> int:
		return _id
	
	
	func server() -> GdUnitTcpServer:
		return get_parent()
	
	
	func rpc_send(p_rpc :RPC) -> void:
		_stream.put_var(p_rpc.serialize(), true)
	
	
	func _process(_delta):
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			return
		receive_packages()
	
	
	func receive_packages() -> void:
		var available_bytes = _stream.get_available_bytes()
		if available_bytes > 0:
			var partial_data = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if partial_data[0] != OK:
				push_error("Error getting data from stream: %s " % partial_data[0])
				return
			else:
				var received_data := partial_data[1] as PackedByteArray
				for package in _read_next_data_packages(received_data):
					var rpc_ = RPC.deserialize(package)
					if rpc_ is RPCClientDisconnect:
						close()
					server().rpc_data.emit(rpc_)
	
	
	func _read_next_data_packages(data_package :PackedByteArray) -> PackedStringArray:
		_readBuffer += data_package.get_string_from_ascii()
		var json_array := _readBuffer.split(GdUnitServerConstants.JSON_RESPONSE_DELIMITER)
		# We need to check if the current data is terminated by the delemiter (data packets can be split unspecifically).
		# If not, store the last part in _readBuffer and complete it on the next data packet that is received
		if not _readBuffer.ends_with(GdUnitServerConstants.JSON_RESPONSE_DELIMITER):
			_readBuffer = json_array[-1]
			json_array.remove_at(json_array.size()-1)
		else:
		# Reset the buffer if a completely terminated packet was received
			_readBuffer = ""
		# remove empty packages
		for index in json_array.size():
			if index < json_array.size() and json_array[index].is_empty():
				json_array.remove_at(index)
		return json_array
	
	
	func console(_message :String) -> void:
		#print_debug("TCP Connection:", _message)
		pass


func _ready():
	_server = TCPServer.new()
	client_connected.connect(Callable(self, "_on_client_connected"))
	client_disconnected.connect(Callable(self, "_on_client_disconnected"))


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()


func start() -> GdUnitResult:
	var server_port := GdUnitServerConstants.GD_TEST_SERVER_PORT
	var err := OK
	for retry in GdUnitServerConstants.DEFAULT_SERVER_START_RETRY_TIMES:
		err = _server.listen(server_port, "127.0.0.1")
		if err != OK:
			prints("GdUnit4: Can't establish server checked port: %d, Error: %s" % [server_port, error_string(err)])
			server_port += 1
			prints("GdUnit4: Retry (%d) ..." % retry)
		else:
			break
	if err != OK:
		if err == ERR_ALREADY_IN_USE:
			return GdUnitResult.error("GdUnit3: Can't establish server, the server is already in use. Error: %s, " % error_string(err))
		return GdUnitResult.error("GdUnit3: Can't establish server. Error: %s." % error_string(err))
	prints("GdUnit4: Test server successfully started checked port: %d" % server_port)
	return GdUnitResult.success(server_port)


func stop() -> void:
	if _server:
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
	console("Client connected %d" % client_id)


func _on_client_disconnected(client_id :int):
	console("Client disconnected %d" % client_id)
	for connection in get_children():
		if connection is TcpConnection and connection.id() == client_id:
			remove_child(connection)



func console(_message :String) -> void:
	#print_debug("TCP Server:", _message)
	pass
