@tool
extends EditorPlugin

func _init():
	add_autoload_singleton("BeehaveGlobalMetrics", "res://addons/beehave/metrics/beehave_global_metrics.gd")
	print("Beehave initialized!")
	
