extends BeehaveTree

class_name BeehaveRoot, "../icons/tree.svg"

const Blackboard = preload("../blackboard.gd")
const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

enum PROCESS_MODE {
	PHYSICS_PROCESS,
	IDLE,
	INPUT
}

export (bool) var enabled = true
export (PROCESS_MODE) var process_mode = PROCESS_MODE.PHYSICS_PROCESS

onready var blackboard = Blackboard.new()

func _ready():
	if self.get_child_count() != 1:
		push_error("Beehave error: Root should have one child")
		disable()
		return
	set_process(enabled and process_mode == PROCESS_MODE.IDLE)
	set_physics_process(enabled and process_mode == PROCESS_MODE.PHYSICS_PROCESS)
	set_process_input(enabled and process_mode == PROCESS_MODE.INPUT)

func _process(delta):
	if process_mode == PROCESS_MODE.IDLE and enabled:
		tick(delta)

func _physics_process(delta):
	if process_mode == PROCESS_MODE.PHYSICS_PROCESS:
		tick(delta)

func _input(event):
	if process_mode == PROCESS_MODE.INPUT and event.is_action_pressed("tick") and enabled:
		tick(1.0 / Engine.iterations_per_second)

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
	set_process(enabled and process_mode == PROCESS_MODE.IDLE)
	set_physics_process(enabled and process_mode == PROCESS_MODE.PHYSICS_PROCESS)
	set_process_input(enabled and process_mode == PROCESS_MODE.INPUT)


func disable():
	self.enabled = false
	set_process(enabled and process_mode == PROCESS_MODE.IDLE)
	set_physics_process(enabled and process_mode == PROCESS_MODE.PHYSICS_PROCESS)
	set_process_input(enabled and process_mode == PROCESS_MODE.INPUT)
