extends Node2D


@onready var beehave_debugger_tab: BeehaveDebuggerTab = %BeehaveDebuggerTab
@onready var beehave_tree: BeehaveTree = %BeehaveTree


func _ready() -> void:
	var tree_data:Dictionary = beehave_tree._get_debugger_data(beehave_tree)
	beehave_debugger_tab.register_tree(tree_data)
	beehave_debugger_tab.start()
