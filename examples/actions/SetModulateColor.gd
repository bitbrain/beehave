extends ActionLeaf

@export var modulate_color:Color = Color.WHITE
@export var interpolation_time:float = 3.0

var current_color
var tween

func tick(actor: Node, _blackboard: Blackboard) -> int:
	
	if current_color != modulate_color and actor.modulate != modulate_color:
		if tween != null:
			tween.stop()
		current_color = modulate_color
		tween = create_tween()\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(actor, "modulate", current_color, interpolation_time)\
		.finished.connect(_finished.bind(actor))
		
	if current_color != null:
		return RUNNING
	else:
		return SUCCESS

func _finished(actor: Node) -> void:
	current_color = null
	tween = null
	if actor is ColorChangingSprite:
		actor.color_changed.emit()
