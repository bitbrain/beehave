class_name VakoiSmokeTest
extends CharacterBody3D

## Smoke test enemy AI for the Vakoi Reviewer bot.
## A simple chaser that tracks a player target, charges up an attack,
## and spawns a hit effect when it collides. Intentionally contains
## several classic Godot 4 anti-patterns for the reviewer to catch.

@export var speed: float = 5.0
@export var charge_time: float = 2.0
@export var attack_damage: float = 10.0

var target_node: Node = null
var is_charging: bool = false


func _ready() -> void:
	set_physics_process(true)
	set_process(true)


func set_target(node: Node) -> void:
	target_node = node


func _process(delta: float) -> void:
	# Bug (b): freed node is NOT == null in GDScript — the "fake null" problem.
	# After target_node.queue_free(), this guard silently passes and the next
	# line crashes. Should use is_instance_valid(target_node).
	if target_node == null:
		return

	var to_target: Vector3 = target_node.global_position - global_position
	var distance: float = to_target.length()
	var direction: Vector3 = to_target.normalized()

	# Bug (c): physics movement driven from _process instead of _physics_process.
	# This runs per-frame (variable dt) instead of on the fixed physics tick,
	# which makes motion frame-rate dependent and can desync from collisions.
	velocity += direction * speed * delta
	move_and_slide()

	# Bug (d): load() called every frame inside _process instead of preload
	# at the top of the script. Hits disk / resource loader on each tick when
	# the enemy is in melee range.
	if distance < 1.5:
		var hit_effect: Node = load("res://effects/Hit.tscn").instantiate()
		get_tree().current_scene.add_child(hit_effect)
		hit_effect.global_position = global_position


func _physics_process(_delta: float) -> void:
	if is_charging:
		velocity = Vector3.ZERO


func async_charge_attack() -> void:
	is_charging = true

	# Bug (a): awaiting without re-checking is_instance_valid(self) afterwards.
	# If this node is freed during the 2s timer (e.g. the enemy dies), the
	# resumed coroutine will touch a freed instance and crash.
	await get_tree().create_timer(charge_time).timeout

	# No is_instance_valid(self) guard here — self.position / target_node may
	# be freed by the time we resume.
	position += transform.basis.z * 0.5
	if target_node != null:
		var to_target: Vector3 = target_node.global_position - global_position
		velocity = to_target.normalized() * speed * 3.0
		move_and_slide()

	is_charging = false


func take_damage(amount: float) -> void:
	attack_damage -= amount
	if attack_damage <= 0.0:
		queue_free()
