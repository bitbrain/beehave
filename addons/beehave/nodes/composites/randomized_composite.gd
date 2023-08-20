@tool
class_name RandomizedComposite extends Composite

const WEIGHTS_PREFIX = "Weights/"

## Sets a predicable seed
@export var random_seed: int = 0:
	set(rs):
		random_seed = rs
		if random_seed != 0:
			seed(random_seed)
		else:
			randomize()

## Wether to use weights for every child or not.
@export var use_weights: bool:
	set(value):
		use_weights = value
		if use_weights:
			_update_weights(get_children())
			_connect_children_changing_signals()
		notify_property_list_changed()

var _weights: Dictionary


func _ready():
	_connect_children_changing_signals()


func _connect_children_changing_signals():
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)


func get_shuffled_children() -> Array[Node]:
	var children_bag: Array[Node] = get_children().duplicate()
	if use_weights:
		var weights: Array[int]
		weights.assign(children_bag.map(func (child): return _weights[child.name]))
		children_bag.assign(_weighted_shuffle(children_bag, weights))
	else:
		children_bag.shuffle()
	return children_bag


## Returns a shuffled version of a given array using the supplied array of weights. 
## Think of weights as the chance of a given item being the first in the array.
func _weighted_shuffle(items: Array, weights: Array[int]) -> Array:
	if len(items) != len(weights):
		push_error("items and weights size mismatch: expected %d weights, got %d instead." % [len(items), len(weights)])
		return items
	
	# This method is based on the weighted random sampling algorithm 
	# by Efraimidis, Spirakis; 2005. This runs in O(n log(n)).
	
	# For each index, it will calculate random_value^(1/weight).
	var chance_calc = func(i): return [i, randf() ** (1.0 / weights[i])]
	var random_distribuition = range(len(items)).map(chance_calc)
	
	# Now we just have to order by the calculated value, descending.
	random_distribuition.sort_custom(func(a, b): return a[1] > b[1])
	
	return random_distribuition.map(func(dist): return items[dist[0]])


func _get_property_list():
	var properties = []

	if use_weights:
		for key in _weights.keys():
			properties.append({
				"name": WEIGHTS_PREFIX + key,
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "1,100"
			})
		
	return properties
	
	
func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with(WEIGHTS_PREFIX):
		var weight_name = property.trim_prefix(WEIGHTS_PREFIX)
		_weights[weight_name] = value
		return true
	
	return false


func _get(property: StringName):
	if property.begins_with(WEIGHTS_PREFIX):
		var weight_name = property.trim_prefix(WEIGHTS_PREFIX)
		return _weights[weight_name]
	
	return null


func _update_weights(children: Array[Node]) -> void:
	var new_weights = {}
	for c in children:
		if _weights.has(c.name):
			new_weights[c.name] = _weights[c.name]
		else:
			new_weights[c.name] = 1
	_weights = new_weights
	notify_property_list_changed()


func _on_child_entered_tree(node: Node):
	_update_weights(get_children())

	var renamed_callable = _on_child_renamed.bind(node.name, node)
	if not node.renamed.is_connected(renamed_callable):
		node.renamed.connect(renamed_callable)


func _on_child_exiting_tree(node: Node):
	var renamed_callable = _on_child_renamed.bind(node.name, node)
	if node.renamed.is_connected(renamed_callable):
		node.renamed.disconnect(renamed_callable)
	
	var children = get_children()
	children.erase(node)
	_update_weights(children)


func _on_child_renamed(old_name: String, renamed_child: Node):
	if old_name == renamed_child.name:
		return # No need to update the weights.
	
	# Disconnect signal with old name...
	renamed_child.renamed\
			.disconnect(_on_child_renamed.bind(old_name, renamed_child))
	# ...and connect with the new name.
	renamed_child.renamed\
			.connect(_on_child_renamed.bind(renamed_child.name, renamed_child))
	
	var original_weight = _weights[old_name]
	_weights.erase(old_name)
	_weights[renamed_child.name] = original_weight
	notify_property_list_changed()


func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"RandomizedComposite")
	return classes
