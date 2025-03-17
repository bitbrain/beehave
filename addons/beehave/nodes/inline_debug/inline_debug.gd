@icon("./inline_debug.svg")
class_name BeehaveInlineDebug
extends PanelContainer

@export var tree: BeehaveTree
@onready var sequence_name: Label = %SequenceName
@onready var action_name: Label = %ActionName
@onready var action_status: Label = %ActionStatus


func _ready() -> void:
	if tree:
		BeehaveGlobalDebugger.action_tick.connect(_on_action_tick)


func _on_action_tick(_sequence_name: String, _action_name: String, _status: int) -> void:
	var status_text: String
	if _status == 0:
		status_text = "SUCCESS"
	elif _status == 1:
		status_text = "FAILURE"
	elif _status == 2:
		status_text = "RUNNING"
	else:
		status_text = "UNKNOWN"
		
	sequence_name.text = "%s" % _sequence_name
	action_name.text = "%s" % _action_name
	action_status.text = "%s" % status_text
