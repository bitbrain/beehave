@tool
@icon("../icons/tree.svg")
class_name BeehaveTree extends Node

## Controls the flow of execution of the entire behavior tree.

enum { SUCCESS, FAILURE, RUNNING }

enum ProcessThread { IDLE, PHYSICS, MANUAL }

signal tree_enabled
signal tree_disabled

## Whether this behavior tree should be enabled or not.
@export var enabled: bool = true:
	set(value):
		enabled = value
		set_physics_process(enabled and process_thread == ProcessThread.PHYSICS)
		set_process(enabled and process_thread == ProcessThread.IDLE)
		if value:
			tree_enabled.emit()
		else:
			interrupt()
			tree_disabled.emit()

	get:
		return enabled

## How often the tree should tick, in frames. The default value of 1 means
## tick() runs every frame.
@export var tick_rate: int = 1

## An optional node path this behavior tree should apply to.
@export_node_path var actor_node_path: NodePath:
	set(anp):
		actor_node_path = anp
		if actor_node_path != null and str(actor_node_path) != "..":
			actor = get_node(actor_node_path.get_as_property_path())
		else:
			actor = get_parent()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Whether to run this tree in a physics or idle thread.
@export var process_thread: ProcessThread = ProcessThread.PHYSICS:
	set(value):
		process_thread = value
		self.enabled = self.enabled and process_thread != ProcessThread.MANUAL
		set_physics_process(enabled and process_thread == ProcessThread.PHYSICS)
		set_process(enabled and process_thread == ProcessThread.IDLE)

## Custom blackboard node. An internal blackboard will be used
## if no blackboard is provided explicitly.
@export var blackboard: Blackboard:
	set(b):
		blackboard = b
		if blackboard and _internal_blackboard:
			remove_child(_internal_blackboard)
			_internal_blackboard.free()
			_internal_blackboard = null
		elif not blackboard and not _internal_blackboard:
			_internal_blackboard = Blackboard.new()
			add_child(_internal_blackboard, false, Node.INTERNAL_MODE_BACK)
	get:
		# in case blackboard is accessed before this node is,
		# we need to ensure that the internal blackboard is used.
		if not blackboard and not _internal_blackboard:
			_internal_blackboard = Blackboard.new()
			add_child(_internal_blackboard, false, Node.INTERNAL_MODE_BACK)
		return blackboard if blackboard else _internal_blackboard

## When enabled, this tree is tracked individually
## as a custom monitor.
@export var custom_monitor = false:
	set(b):
		custom_monitor = b
		if custom_monitor and _process_time_metric_name != "":
			Performance.add_custom_monitor(
				_process_time_metric_name, _get_process_time_metric_value
			)
			_get_global_metrics().register_tree(self)
		else:
			if _process_time_metric_name != "":
				# Remove tree metric from the engine
				Performance.remove_custom_monitor(_process_time_metric_name)
				_get_global_metrics().unregister_tree(self)

			BeehaveDebuggerMessages.unregister_tree(get_instance_id())

@export var actor: Node:
	set(a):
		actor = a
		if actor == null:
			actor = get_parent()
		if Engine.is_editor_hint():
			update_configuration_warnings()

var status: int = -1
var last_tick: int = -1

var _internal_blackboard: Blackboard
var _process_time_metric_name: String
var _process_time_metric_value: float = 0.0
var _can_send_message: bool = false


func _ready() -> void:
	var connect_scene_tree_signal = func(signal_name: String, is_added: bool):
		if not get_tree().is_connected(signal_name, _on_scene_tree_node_added_removed.bind(is_added)):
			get_tree().connect(signal_name, _on_scene_tree_node_added_removed.bind(is_added))
	connect_scene_tree_signal.call("node_added", true)
	connect_scene_tree_signal.call("node_removed", false)

	if not process_thread:
		process_thread = ProcessThread.PHYSICS

	if not actor:
		if actor_node_path:
			actor = get_node(actor_node_path)
		else:
			actor = get_parent()

	if not blackboard:
		# invoke setter to auto-initialise the blackboard.
		self.blackboard = null

	# Get the name of the parent node name for metric
	_process_time_metric_name = (
		"beehave [microseconds]/process_time_%s-%s" % [actor.name, get_instance_id()]
	)

	set_physics_process(enabled and process_thread == ProcessThread.PHYSICS)
	set_process(enabled and process_thread == ProcessThread.IDLE)

	# Register custom metric to the engine
	if custom_monitor and not Engine.is_editor_hint():
		Performance.add_custom_monitor(_process_time_metric_name, _get_process_time_metric_value)
		_get_global_metrics().register_tree(self)

	if Engine.is_editor_hint():
		update_configuration_warnings.call_deferred()
	else:
		# Ensure the local debugger knows about the tree *before* telling the editor.
		_get_global_debugger().register_tree(self)
		BeehaveDebuggerMessages.register_tree(_get_debugger_data(self))


func _on_scene_tree_node_added_removed(node: Node, is_added: bool) -> void:
	if Engine.is_editor_hint():
		return

	if node is BeehaveNode and is_ancestor_of(node):
		var sgnal := node.ready if is_added else node.tree_exited
		if is_added:
			sgnal.connect(
				func() -> void: BeehaveDebuggerMessages.register_tree(_get_debugger_data(self)),
				CONNECT_ONE_SHOT
			)
		else:
			sgnal.connect(
				func() -> void:
					BeehaveDebuggerMessages.unregister_tree(get_instance_id())
					request_ready()
			)


func _physics_process(_delta: float) -> void:
	tick()


func _process(_delta: float) -> void:
	tick()


func tick() -> int:
	if Engine.is_editor_hint():
		return -1
	if last_tick != -1 and last_tick < tick_rate - 1:
		last_tick += 1
		return -1

	last_tick = 0

	# Start timing for metric
	var start_time = Time.get_ticks_usec()
	blackboard.set_value("can_send_message", _can_send_message)

	if _can_send_message and not Engine.is_editor_hint():
		BeehaveDebuggerMessages.process_begin(get_instance_id(), blackboard.get_debug_data())

	if actor == null or get_child_count() == 0:
		return FAILURE
	var child := self.get_child(0)
	if status != RUNNING:
		child.before_run(actor, blackboard)

	status = child.tick(actor, blackboard)
	if _can_send_message:
		BeehaveDebuggerMessages.process_tick(child.get_instance_id(), status, blackboard.get_debug_data())
		BeehaveDebuggerMessages.process_tick(get_instance_id(), status, blackboard.get_debug_data())

	# Clear running action if nothing is running
	if status != RUNNING:
		blackboard.set_value("running_action", null, str(actor.get_instance_id()))
		child.after_run(actor, blackboard)
		
	if _can_send_message and not Engine.is_editor_hint():
		BeehaveDebuggerMessages.process_end(get_instance_id(), blackboard.get_debug_data())

	# Check the cost for this frame and save it for metric report
	_process_time_metric_value = Time.get_ticks_usec() - start_time
	
	return status


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if actor == null:
		warnings.append("Configure target node on tree")

	if get_children().any(func(x): return not (x is BeehaveNode)):
		warnings.append("All children of this node should inherit from BeehaveNode class.")

	if get_child_count() != 1:
		warnings.append("BeehaveTree should have exactly one child node.")

	return warnings


## Returns the currently running action
func get_running_action() -> ActionLeaf:
	return blackboard.get_value("running_action", null, str(actor.get_instance_id()))


## Returns the last condition that was executed
func get_last_condition() -> ConditionLeaf:
	return blackboard.get_value("last_condition", null, str(actor.get_instance_id()))


## Returns the status of the last executed condition
func get_last_condition_status() -> String:
	if blackboard.has_value("last_condition_status", str(actor.get_instance_id())):
		var status = blackboard.get_value(
			"last_condition_status", null, str(actor.get_instance_id())
		)
		if status == SUCCESS:
			return "SUCCESS"
		elif status == FAILURE:
			return "FAILURE"
		else:
			return "RUNNING"
	return ""


## interrupts this tree if anything was running
func interrupt() -> void:
	if self.get_child_count() != 0:
		var first_child = self.get_child(0)
		if "interrupt" in first_child:
			first_child.interrupt(actor, blackboard)


## Enables this tree.
func enable() -> void:
	self.enabled = true


## Disables this tree.
func disable() -> void:
	self.enabled = false


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		# Skip this when running in editor
		return
	if custom_monitor:
		if _process_time_metric_name != "":
			# Remove tree metric from the engine
			Performance.remove_custom_monitor(_process_time_metric_name)
		_get_global_metrics().unregister_tree(self)
		BeehaveDebuggerMessages.unregister_tree(get_instance_id())


# Called by the engine to profile this tree
func _get_process_time_metric_value() -> int:
	return int(_process_time_metric_value)


func _get_debugger_data(node: Node) -> Dictionary:
	if not (node is BeehaveTree or node is BeehaveNode):
		return {}

	var data := {
		path = node.get_path(),
		name = node.name,
		type = node.get_class_name(),
		id = str(node.get_instance_id())
	}
	if node.get_child_count() > 0:
		data.children = []
	for child in node.get_children():
		var child_data := _get_debugger_data(child)
		if not child_data.is_empty():
			data.children.push_back(child_data)
	return data


func get_class_name() -> Array[StringName]:
	return [&"BeehaveTree"]


# required to avoid lifecycle issues on initial load
# due to loading order problems with autoloads
func _get_global_metrics() -> Node:
	return get_tree().root.get_node("BeehaveGlobalMetrics")


# required to avoid lifecycle issues on initial load
# due to loading order problems with autoloads
func _get_global_debugger() -> Node:
	return get_tree().root.get_node("BeehaveGlobalDebugger")
