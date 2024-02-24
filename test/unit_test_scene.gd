class_name UnitTestScene extends Node2D

@onready var beehave_tree:BeehaveTree = %BeehaveTree
@onready var blackboard:BeehaveBlackboard = %BeehaveBlackboard
@onready var test_node = $Node2D
@onready var count_up_action = %CountUpAction
@onready var shared_action_1 = %SharedCountUpAction1
@onready var shared_action_2 = %SharedCountUpAction2


func _ready() -> void:
	blackboard.set_value("a", 12)
	blackboard.set_value("b", 14)
	blackboard.set_value("c", 16)
