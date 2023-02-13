## Controls the flow of execution of the entire behaviour tree.
@tool
@icon("../icons/tree.svg")
class_name BeehaveTree extends Node

enum {
	SUCCESS,
	FAILURE,
	RUNNING
}

signal tree_enabled
signal tree_disabled

@export var enabled: bool = true:
	set(value):
		enabled = value
		set_physics_process(enabled)
		
		if value:
			tree_enabled.emit()
		else:
			interrupt()
			tree_disabled.emit()
	
	get:
		return enabled

@export_node_path var actor_node_path : NodePath
@export var blackboard:Blackboard:
	set(b):
		blackboard = b
		if blackboard and internal_blackboard:
			remove_child(internal_blackboard)
			internal_blackboard.free()
			internal_blackboard = null
		elif not blackboard and not internal_blackboard:
			internal_blackboard = Blackboard.new()
			add_child(internal_blackboard)

var actor : Node
var status : int = -1
var internal_blackboard: Blackboard

var _process_time_metric_name : String
var _process_time_metric_value : float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if not blackboard:
		internal_blackboard = Blackboard.new()
		add_child(internal_blackboard)

	actor = get_parent()
	if actor_node_path:
		actor = get_node(actor_node_path)
		
	# Get the name of the parent node name for metric
	var parent_name = actor.name
	_process_time_metric_name = "beehave/%s-%s-process_time" % [parent_name, get_instance_id()]
	
	# Register custom metric to the engine
	Performance.add_custom_monitor(_process_time_metric_name, _get_process_time_metric_value)
	BeehaveGlobalMetrics.register_tree(self)

	set_physics_process(enabled)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	# Start timing for metric
	var start_time = Time.get_ticks_usec()
	
	_get_current_blackboard().set_value("delta", delta, str(actor.get_instance_id()))
	
	for child in get_children():
		if child is BeehaveNode:
			status = child.tick(actor, _get_current_blackboard())

	# Clear running action if nothing is running
	if status != RUNNING:
		_get_current_blackboard().set_value("running_action", null, str(actor.get_instance_id()))
	
	# Check the cost for this frame and save it for metric report
	_process_time_metric_value = (Time.get_ticks_usec() - start_time) / 1000.0
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	
	if get_children().any(func(x): return not (x is BeehaveNode)):
		warnings.append("All children of this node should inherit from BeehaveNode class.")
		
	if get_child_count() != 1:
		warnings.append("BeehaveTree should have exactly one child node.")
	
	return warnings


func get_running_action() -> ActionLeaf:
	return _get_current_blackboard().get_value("running_action", null, str(actor.get_instance_id()))


func get_last_condition() -> ConditionLeaf:
	return _get_current_blackboard().get_value("last_condition", null, str(actor.get_instance_id()))


func get_last_condition_status() -> String:
	if _get_current_blackboard().has_value("last_condition_status", str(actor.get_instance_id())):
		var status = _get_current_blackboard().get_value("last_condition_status", null, str(actor.get_instance_id()))
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
			first_child.interrupt(actor, _get_current_blackboard())


func enable() -> void:
	self.enabled = true


func disable() -> void:
	self.enabled = false


func _exit_tree() -> void:
	if _process_time_metric_name != '':
		# Remove tree metric from the engine
		Performance.remove_custom_monitor(_process_time_metric_name)
		BeehaveGlobalMetrics.unregister_tree(self)


# Called by the engine to profile this tree
func _get_process_time_metric_value() -> float:
	return _process_time_metric_value
	

func _get_current_blackboard() -> Blackboard:
	return blackboard if blackboard else internal_blackboard
