## Controls the flow of execution of the entire behaviour tree.
@tool
class_name BeehaveRoot extends BeehaveTree
@icon("../icons/tree.svg")


@export var enabled: bool = true:
	set(value):
		enabled = value
		set_physics_process(enabled)
	get:
		return enabled

@export_node_path var actor_node_path : NodePath

var actor : Node

@onready var blackboard: Blackboard = Blackboard.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if self.get_child_count() != 1:
		push_error("Beehave error: Root %s should have one child (NodePath: %s)" % [self.name, self.get_path()])
		disable()
		return

	actor = get_parent()
	if actor_node_path:
		actor = get_node(actor_node_path)

	set_physics_process(enabled)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	blackboard.set_value("delta", delta)
	var status = self.get_child(0).tick(actor, blackboard)

	# Updates the current running action.
	var running_action = get_running_action() if status == RUNNING else null
	blackboard.set_value("running_action", running_action)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	
	if get_child_count() != 1:
		warnings.append("BeehaveRoot should have exactly one child node.")
	
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
	if blackboard.has_value("last_condition"):
		return blackboard.get_value("last_condition")
	return null


func get_last_condition_status() -> String:
	if blackboard.has_value("last_condition_status"):
		var status = blackboard.get_value("last_condition_status")
		if status == SUCCESS:
			return "SUCCESS"
		elif status == FAILURE:
			return "FAILURE"
		else:
			return "RUNNING"
	return ""


func enable() -> void:
	enabled = true


func disable() -> void:
	enabled = false
