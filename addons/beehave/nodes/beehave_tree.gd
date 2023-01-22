## Controls the flow of execution of the entire behaviour tree.
@tool
@icon("../icons/tree.svg")
class_name BeehaveTree extends Node

enum {
	SUCCESS,
	FAILURE,
	RUNNING
}


@export var enabled: bool = true:
	set(value):
		enabled = value
		set_physics_process(enabled)
	get:
		return enabled

@export_node_path var actor_node_path : NodePath
@export var blackboard:Blackboard

var actor : Node


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if self.get_child_count() != 1:
		push_error("Beehave error: Root %s should have one child (NodePath: %s)" % [self.name, self.get_path()])
		disable()
		return
		
	if not blackboard:
		blackboard = Blackboard.new()

	actor = get_parent()
	if actor_node_path:
		actor = get_node(actor_node_path)

	set_physics_process(enabled)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	blackboard.set_value("delta", delta, str(actor.get_instance_id()))
	var status = self.get_child(0).tick(actor, blackboard)

	# Clear running action if nothing is running
	if status != RUNNING:
		blackboard.set_value("running_action", null, str(actor.get_instance_id()))
	


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	
	if get_children().any(func(x): return not (x is BeehaveNode)):
		warnings.append("All children of this node should inherit from BeehaveNode class.")
		
	if get_child_count() != 1:
		warnings.append("BeehaveTree should have exactly one child node.")
	
	return warnings


func get_running_action() -> ActionLeaf:
	return blackboard.get_value("running_action", null, str(actor.get_instance_id()))


func get_last_condition() -> ConditionLeaf:
	return blackboard.get_value("last_condition", null, str(actor.get_instance_id()))


func get_last_condition_status() -> String:
	if blackboard.has_value("last_condition_status", str(actor.get_instance_id())):
		var status = blackboard.get_value("last_condition_status", null, str(actor.get_instance_id()))
		if status == SUCCESS:
			return "SUCCESS"
		elif status == FAILURE:
			return "FAILURE"
		else:
			return "RUNNING"
	return ""


func enable() -> void:
	self.enabled = true


func disable() -> void:
	self.enabled = false
