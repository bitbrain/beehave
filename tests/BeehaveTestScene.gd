extends Node2D

@onready var sprite := $Sprite2D

func _process(delta:float) -> void:
	if Input.is_action_pressed("ui_left"):
		sprite.position.x -= 200 * delta
		
	if Input.is_action_pressed("ui_right"):
		sprite.position.x += 200 * delta
		
	if Input.is_action_pressed("ui_up"):
		sprite.position.y -= 200 * delta
		
	if Input.is_action_pressed("ui_down"):
		sprite.position.y += 200 * delta
