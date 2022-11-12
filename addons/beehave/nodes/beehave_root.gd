class_name BeehaveRoot extends BeehaveTree
@icon("../icons/tree.svg")

const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

@export var enabled : bool = true

@export_node_path var actor_node_path : NodePath

var actor : Node

@onready var blackboard: Blackboard = Blackboard.new()

func _ready():
	if self.get_child_count() != 1:
		push_error("Beehave error: Root %s should have one child (NodePath: %s)" % [self.name, self.get_path()])
		disable()
		return

	actor = get_parent()
	if actor_node_path:
		actor = get_node(actor_node_path)

	set_physics_process(enabled)

func _physics_process(delta):
	blackboard.set_value("delta", delta)

	var status = self.get_child(0).tick(actor, blackboard)

	if status != RUNNING:
		blackboard.set_value("running_action", null)

func get_running_action():
	if blackboard.has_value("running_action"):
		return blackboard.get_value("running_action")
	return null

func get_last_condition():
	if blackboard.has_value("last_condition"):
		return blackboard.get_value("last_condition")
	return null

func get_last_condition_status():
	if blackboard.has_value("last_condition_status"):
		var status = blackboard.get_value("last_condition_status")
		if status == SUCCESS:
			return "SUCCESS"
		elif status == FAILURE:
			return "FAILURE"
		else:
			return "RUNNING"
	return ""


func enable():
	self.enabled = true
	set_physics_process(true)


func disable():
	self.enabled = false
	set_physics_process(false)
