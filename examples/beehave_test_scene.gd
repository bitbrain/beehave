extends Node2D

@onready var sprite := $ColorChangingSprite
@onready var tree := %BeehaveTree
@onready var condition_label := %ConditionLabel
@onready var action_label := %ActionLabel


func _process(delta:float) -> void:
	if Input.is_action_pressed("ui_left"):
		sprite.position.x -= 200 * delta

	if Input.is_action_pressed("ui_right"):
		sprite.position.x += 200 * delta

	if Input.is_action_pressed("ui_up"):
		sprite.position.y -= 200 * delta

	if Input.is_action_pressed("ui_down"):
		sprite.position.y += 200 * delta

	if tree.get_last_condition():
		condition_label.text = str(tree.get_last_condition(), " -> ", tree.get_last_condition_status())
	else:
		condition_label.text = "no condition"

	if tree.get_running_action():
		action_label.text = str(tree.get_running_action(), " -> RUNNING")
	else:
		action_label.text = "no running action"
