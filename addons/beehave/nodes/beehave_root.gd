extends BeehaveTree

class_name BeehaveRoot, "../icons/tree.svg"

const Blackboard = preload("../blackboard.gd")
const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

enum PROCESS_MODE {
	PHYSICS_PROCESS,
	IDLE,
	MANUAL
}

export (PROCESS_MODE) var process_mode = PROCESS_MODE.PHYSICS_PROCESS setget set_process_mode
export (bool) var enabled = true

onready var blackboard = Blackboard.new()

func _ready():
	if self.get_child_count() != 1:
		push_error("Beehave error: Root should have one child")
		disable()
		return
	set_process(enabled and process_mode == PROCESS_MODE.IDLE)
	set_physics_process(enabled and process_mode == PROCESS_MODE.PHYSICS_PROCESS)

func _process(delta):
	tick(delta)

func _physics_process(delta):
	tick(delta)

func tick(delta):
	blackboard.set("delta", delta)

	var status = self.get_child(0).tick(get_parent(), blackboard)

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
	set_process(process_mode == PROCESS_MODE.IDLE)
	set_physics_process(process_mode == PROCESS_MODE.PHYSICS_PROCESS)

func disable():
	self.enabled = false
	set_process(self.enabled)
	set_physics_process(self.enabled)

func set_process_mode(value):
	process_mode = value
	set_process(process_mode == PROCESS_MODE.IDLE)
	set_physics_process(process_mode == PROCESS_MODE.PHYSICS_PROCESS)
