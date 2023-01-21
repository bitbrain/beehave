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

	# Updates the current running action.
	var running_action = get_running_action() if status == RUNNING else null
	blackboard.set_value("running_action", running_action, str(actor.get_instance_id()))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	
	if get_children().any(func(x): return not (x is BeehaveNode)):
		warnings.append("All children of this node should inherit from BeehaveNode class.")
		
	if get_child_count() != 1:
		warnings.append("BeehaveTree should have exactly one child node.")
	
	return warnings


func get_running_action() -> ActionLeaf:
	var node = get_child(0)
	while node != null:
		if node is Composite:
			node = (node as Composite).running_child
		elif node is ActionLeaf:
			return node
	
	push_error("Beehave error: Could not find running action in tree root '%s'." % name)
	return null


func get_last_condition() -> Variant:
	if blackboard.has_value("last_condition", str(actor.get_instance_id())):
		return blackboard.get_value("last_condition", str(actor.get_instance_id()))
	return null


func get_last_condition_status() -> String:
	if blackboard.has_value("last_condition_status", str(actor.get_instance_id())):
		var status = blackboard.get_value("last_condition_status", str(actor.get_instance_id()))
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
