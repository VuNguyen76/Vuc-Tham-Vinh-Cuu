extends Area2D

# ponytail: minimal high-speed boss projectile

@export var speed: float = 340.0
@export var damage: float = 120.0
var direction: Vector2 = Vector2.DOWN
var lifetime: float = 5.0
var homing_target: Node2D = null
var homing_turn_speed: float = 0.0

func setup(dir: Vector2, spd: float = 340.0, dmg: float = 120.0, target: Node2D = null, turn_spd: float = 0.0, tint: Color = Color.WHITE) -> void:
	direction = dir.normalized()
	speed = spd
	damage = dmg
	homing_target = target
	homing_turn_speed = turn_spd
	modulate = tint

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	if homing_target and is_instance_valid(homing_target) and homing_turn_speed > 0.0:
		var target_dir = (homing_target.global_position - global_position).normalized()
		direction = direction.slerp(target_dir, homing_turn_speed * delta).normalized()

	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and body.has_method("take_hit"):
		body.take_hit(damage, direction)
		queue_free()
