class_name CmdCommandHandler
extends RefCounted

const CB_SINGLE_ARG = 0
const CB_MULTI_ARGS = 1

var _cmd_options :CmdOptions
# holds the command callbacks by key:<cmd_name>:String and value: [<cb single arg>, <cb multible args>]:Array
var _command_cbs :Dictionary

const NO_CB := Callable()

# we only able to check cb function name since Godot 3.3.x
var _enhanced_fr_test := false


func _init(cmd_options: CmdOptions):
	_cmd_options = cmd_options
	var major: int = Engine.get_version_info()["major"]
	var minor: int = Engine.get_version_info()["minor"]
	if major == 3 and minor == 3:
		_enhanced_fr_test = true


# register a callback function for given command
# cmd_name short name of the command
# fr_arg a funcref to a function with a single argument
func register_cb(cmd_name: String, cb: Callable = NO_CB) -> CmdCommandHandler:
	var registered_cb: Array = _command_cbs.get(cmd_name, [NO_CB, NO_CB])
	if registered_cb[CB_SINGLE_ARG]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_cb[CB_SINGLE_ARG] = cb
	_command_cbs[cmd_name] = registered_cb
	return self


# register a callback function for given command
# cb a funcref to a function with a variable number of arguments but expects all parameters to be passed via a single Array.
func register_cbv(cmd_name: String, cb: Callable) -> CmdCommandHandler:
	var registered_cb: Array = _command_cbs.get(cmd_name, [NO_CB, NO_CB])
	if registered_cb[CB_MULTI_ARGS]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_cb[CB_MULTI_ARGS] = cb
	_command_cbs[cmd_name] = registered_cb
	return self


func _validate() -> Result:
	var errors: = PackedStringArray()
	var registered_cbs: = Dictionary()
	
	for cmd_name in _command_cbs.keys():
		var cb: Callable = _command_cbs[cmd_name][CB_SINGLE_ARG] if _command_cbs[cmd_name][CB_SINGLE_ARG] else _command_cbs[cmd_name][CB_MULTI_ARGS]
		if cb != NO_CB and not cb.is_valid():
			errors.append("Invalid function reference for command '%s', Check the function reference!" % cmd_name)
		if _cmd_options.get_option(cmd_name) == null:
			errors.append("The command '%s' is unknown, verify your CmdOptions!" % cmd_name)
		# verify for multiple registered command callbacks
		if _enhanced_fr_test and cb != NO_CB:
			var cb_method: = cb.get_method()
			if registered_cbs.has(cb_method):
				var already_registered_cmd = registered_cbs[cb_method] 
				errors.append("The function reference '%s' already registerd for command '%s'!" % [cb_method, already_registered_cmd])
			else:
				registered_cbs[cb_method] = cmd_name
	if errors.is_empty():
		return Result.success(true)
	else:
		return Result.error("\n".join(errors))


func execute(commands :Array) -> Result:
	var result := _validate()
	if result.is_error():
		return result
	for index in commands.size():
		var cmd :CmdCommand = commands[index]
		assert(cmd is CmdCommand) #,"commands contains invalid command object '%s'" % cmd)
		var cmd_name := cmd.name()
		if _command_cbs.has(cmd_name):
			var cb_s :Callable = _command_cbs.get(cmd_name)[CB_SINGLE_ARG]
			var cb_m :Callable = _command_cbs.get(cmd_name)[CB_MULTI_ARGS]
			if cmd.arguments().is_empty():
				cb_s.call()
			else:
				if cmd.arguments().size() == 1:
					cb_s.call(cmd.arguments()[CB_SINGLE_ARG])
				else:
					cb_m.callv(cmd.arguments())
	return Result.success(true)
