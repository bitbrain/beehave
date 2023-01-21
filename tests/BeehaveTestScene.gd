extends Node2D

@onready var sprite := $Sprite2D
@onready var tree := %BeehaveTree
@onready var label := %Label


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
		label.text = str(tree.get_last_condition(), " -> ", tree.get_last_condition_status())
