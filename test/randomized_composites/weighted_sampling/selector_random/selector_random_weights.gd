extends Node2D


@onready var selector: SelectorRandomComposite = %SelectorRandom
@onready var blackboard: Blackboard = $Blackboard
@onready var label: Label = $Label

# key: Node name | value: counter key
var _counter_keys: Dictionary = {}

func _ready():
	for action in selector.get_children():
		if "key" in action:
			_counter_keys[action.name] = action.key


func _process(_delta:float):
	var debug_text = ""
	
	var sample_size = 0
	for key in _counter_keys.values():
		var count = blackboard.get_value(key, 0)
		debug_text += "%s: %d\n" % [key, count]
		sample_size += count
	
	debug_text += "total: %d" % sample_size
	
	label.text = debug_text


func get_final_results() -> Dictionary:
	var sample_size = 0
	var results = {}
	
	for key in _counter_keys.values():
		var count = blackboard.get_value(key, 0)
		sample_size += count
	
	for action_name in _counter_keys.keys():
		var value = blackboard.get_value(_counter_keys[action_name], 0)
		var perc = (float(value) / float(sample_size)) * 100.0
		results[action_name] = perc
		
	return results


func set_weights(common: int, uncommon: int, rare: int, extraordinary: int):
	selector.set("Weights/Common", common)
	selector.set("Weights/Uncommon", uncommon)
	selector.set("Weights/Rare", rare)
	selector.set("Weights/Extraordinary", extraordinary)

