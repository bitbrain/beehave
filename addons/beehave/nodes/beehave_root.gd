extends BeehaveTree

class_name BeehaveRoot, "../icons/tree.svg"

const Blackboard = preload("../blackboard.gd")
const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

enum ProcessMode {
	PHYSICS_PROCESS,
	IDLE,
	MANUAL
}

export (ProcessMode) var process_mode = ProcessMode.PHYSICS_PROCESS setget set_process_mode
export (bool) var enabled = true

export (NodePath) var actor_node_path

var actor : Node

onready var blackboard = Blackboard.new()

func _ready():
	if self.get_child_count() != 1:
		push_error("Beehave error: Root %s should have one child (NodePath: %s)" % [self.name, self.get_path()])
		disable()
		return

	actor = get_parent()
	if actor_node_path:
		actor = get_node(actor_node_path)

	set_process_mode(self.process_mode)

func _process(delta):
	tick(delta)
  
func _physics_process(delta):
	tick(delta)

func tick(delta):
	blackboard.set("delta", delta)

	var status = self.get_child(0).tick(actor, blackboard)
	
	if status != RUNNING:
		blackboard.set("running_action", null)

func get_running_action():
	if blackboard.has("running_action"):
		return blackboard.get("running_action")
	return null

func get_last_condition():
	if blackboard.has("last_condition"):
		return blackboard.get("last_condition")
	return null

func get_last_condition_status():
	if blackboard.has("last_condition_status"):
		var status = blackboard.get("last_condition_status")
		if status == SUCCESS:
			return "SUCCESS"
		elif status == FAILURE:
			return "FAILURE"
		else:
			return "RUNNING"
	return ""

func enable():
	self.enabled = true
	set_process_mode(self.process_mode)

func disable():
	self.enabled = false
	set_process(self.enabled)
	set_physics_process(self.enabled)

func set_process_mode(value):
	process_mode = value
	set_process(process_mode == ProcessMode.IDLE)
	set_physics_process(process_mode == ProcessMode.PHYSICS_PROCESS)
