extends CharacterBody2D
class_name Monster

# Dynamic LPC monster minion/elite controller with 4-directional animations, AI pathing, combat attacks, and loot drops

@export var monster_type: String = "skeleton"

var max_health: float = 140.0
var current_health: float = 140.0
var move_speed: float = 130.0
var attack_damage: float = 16.0
var attack_range: float = 46.0
var attack_cooldown: float = 1.2
var attack_timer: float = 0.0

var is_attacking: bool = false
var is_dead: bool = false
var anim_time: float = 0.0
var current_row: int = 2 # 0: Up, 1: Left, 2: Down, 3: Right

var target_player: Node2D = null

var tex_walk: Texture2D = null
var tex_slash: Texture2D = null
var tex_hurt: Texture2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hp_bar: ProgressBar = $HpBar
@onready var name_label: Label = $NameLabel

const MONSTER_CONFIGS: Dictionary = {
	"skeleton": {
		"name": "monster_skeleton",
		"hp": 140.0,
		"spd": 135.0,
		"atk": 18.0,
		"cd": 1.1,
		"color": Color(0.95, 0.95, 1.0),
		"scale": Vector2(1.0, 1.0),
		"walk": "res://assets/monsters/skeleton/walk.png",
		"slash": "res://assets/monsters/skeleton/slash.png",
		"hurt": "res://assets/monsters/skeleton/hurt.png",
		"loot": [
			{"id": "mat_stone", "min": 1, "max": 2, "chance": 0.8},
			{"id": "mat_dust", "min": 2, "max": 4, "chance": 0.9},
			{"id": "item_heal_potion", "min": 1, "max": 1, "chance": 0.5},
			{"id": "chest_wood", "min": 1, "max": 1, "chance": 0.25}
		]
	},
	"zombie": {
		"name": "monster_zombie",
		"hp": 220.0,
		"spd": 85.0,
		"atk": 25.0,
		"cd": 1.4,
		"color": Color(0.5, 0.95, 0.5),
		"scale": Vector2(1.0, 1.0),
		"walk": "res://assets/monsters/zombie/walk.png",
		"slash": "res://assets/monsters/zombie/slash.png",
		"hurt": "res://assets/monsters/zombie/hurt.png",
		"loot": [
			{"id": "mat_dust", "min": 3, "max": 6, "chance": 0.95},
			{"id": "mat_stone", "min": 1, "max": 2, "chance": 0.6},
			{"id": "item_heal_potion", "min": 1, "max": 1, "chance": 0.45},
			{"id": "chest_wood", "min": 1, "max": 1, "chance": 0.3}
		]
	},
	"goblin": {
		"name": "monster_goblin",
		"hp": 110.0,
		"spd": 185.0,
		"atk": 22.0,
		"cd": 0.85,
		"color": Color(0.9, 0.8, 0.3),
		"scale": Vector2(0.85, 0.85),
		"walk": "res://assets/monsters/goblin/walk.png",
		"slash": "res://assets/monsters/goblin/slash.png",
		"hurt": "res://assets/monsters/goblin/hurt.png",
		"loot": [
			{"id": "mat_gem", "min": 1, "max": 1, "chance": 0.5},
			{"id": "mat_shard", "min": 1, "max": 1, "chance": 0.4},
			{"id": "item_heal_potion", "min": 1, "max": 1, "chance": 0.4},
			{"id": "chest_silver", "min": 1, "max": 1, "chance": 0.3}
		]
	},
	"orc": {
		"name": "monster_orc",
		"hp": 380.0,
		"spd": 125.0,
		"atk": 38.0,
		"cd": 1.3,
		"color": Color(1.0, 0.4, 0.3),
		"scale": Vector2(1.15, 1.15),
		"walk": "res://assets/monsters/orc/walk.png",
		"slash": "res://assets/monsters/orc/slash.png",
		"hurt": "res://assets/monsters/orc/hurt.png",
		"loot": [
			{"id": "mat_stone", "min": 2, "max": 4, "chance": 0.95},
			{"id": "mat_gem", "min": 1, "max": 2, "chance": 0.65},
			{"id": "item_heal_potion", "min": 1, "max": 1, "chance": 0.5},
			{"id": "chest_gold", "min": 1, "max": 1, "chance": 0.35}
		]
	},
	"minotaur": {
		"name": "monster_minotaur",
		"hp": 850.0,
		"spd": 110.0,
		"atk": 58.0,
		"cd": 1.6,
		"color": Color(0.9, 0.3, 0.9),
		"scale": Vector2(1.35, 1.35),
		"walk": "res://assets/monsters/minotaur/walk.png",
		"slash": "res://assets/monsters/minotaur/slash.png",
		"hurt": "res://assets/monsters/minotaur/hurt.png",
		"loot": [
			{"id": "mat_shard", "min": 2, "max": 4, "chance": 0.85},
			{"id": "mat_gem", "min": 2, "max": 3, "chance": 0.85},
			{"id": "item_heal_potion", "min": 1, "max": 2, "chance": 0.6},
			{"id": "chest_mythic", "min": 1, "max": 1, "chance": 0.4}
		]
	}
}

func _ready() -> void:
	add_to_group("monsters")
	add_to_group("enemies")
	setup_monster(monster_type)

func setup_monster(m_type: String) -> void:
	monster_type = m_type
	var cfg = MONSTER_CONFIGS.get(m_type, MONSTER_CONFIGS["skeleton"])
	max_health = cfg["hp"]
	current_health = max_health
	move_speed = cfg["spd"]
	attack_damage = cfg["atk"]
	attack_cooldown = cfg["cd"]

	tex_walk = load(cfg["walk"])
	tex_slash = load(cfg["slash"])
	tex_hurt = load(cfg["hurt"])

	if sprite:
		sprite.texture = tex_walk
		sprite.hframes = 9
		sprite.vframes = 4
		sprite.frame = 18 # Down idle

	scale = cfg["scale"]
	name_label.text = Localization.tr_text(cfg["name"])
	name_label.modulate = cfg["color"]

	hp_bar.max_value = max_health
	hp_bar.value = current_health

func _physics_process(delta: float) -> void:
	if is_dead: return

	if attack_timer > 0.0:
		attack_timer -= delta

	if not target_player or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			target_player = players[0]
		return

	var dist = global_position.distance_to(target_player.global_position)
	var dir_to_player = (target_player.global_position - global_position).normalized()

	# Determine facing direction row (LPC: 0=Up, 1=Left, 2=Down, 3=Right)
	if abs(dir_to_player.x) > abs(dir_to_player.y):
		current_row = 3 if dir_to_player.x > 0 else 1
	else:
		current_row = 2 if dir_to_player.y > 0 else 0

	if is_attacking:
		return

	# Attack trigger
	if dist <= attack_range and attack_timer <= 0.0:
		_perform_attack(dir_to_player)
		return

	# Monster separation force (prevent stacking)
	var separation = Vector2.ZERO
	var nearby_monsters = get_tree().get_nodes_in_group("monsters")
	for m in nearby_monsters:
		if m != self and is_instance_valid(m):
			var d = global_position.distance_to(m.global_position)
			if d > 0 and d < 42.0:
				separation += (global_position - m.global_position).normalized() * (42.0 - d) * 3.0

	# Movement towards player
	velocity = (dir_to_player * move_speed) + separation
	move_and_slide()
	global_position.x = clampf(global_position.x, 105.0, 1175.0)
	global_position.y = clampf(global_position.y, 125.0, 645.0)

	# Walk animation (9 frames per row)
	if sprite.texture != tex_walk:
		sprite.texture = tex_walk
		sprite.hframes = 9
		sprite.vframes = 4

	anim_time += delta * 11.0
	var col = (int(anim_time) % 8) + 1
	sprite.frame = current_row * 9 + col

func _perform_attack(attack_dir: Vector2) -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	velocity = Vector2.ZERO

	if tex_slash:
		sprite.texture = tex_slash
		sprite.hframes = 6
		sprite.vframes = 4

	# Play 6-frame attack animation
	for f in range(6):
		if is_dead: return
		sprite.frame = current_row * 6 + f
		if f == 3: # Hit impact frame
			if target_player and is_instance_valid(target_player):
				var d = global_position.distance_to(target_player.global_position)
				if d <= attack_range + 20.0 and target_player.has_method("take_hit"):
					target_player.take_hit(attack_damage, attack_dir)
		await get_tree().create_timer(0.06).timeout

	if is_dead: return
	sprite.texture = tex_walk
	sprite.hframes = 9
	sprite.vframes = 4
	is_attacking = false

func take_damage(dmg: float, is_crit: bool, attacker: String, hit_pos: Vector2) -> void:
	if is_dead: return

	current_health -= dmg
	hp_bar.value = current_health

	# Knockback impact
	var knock_dir = (global_position - hit_pos).normalized()
	velocity += knock_dir * 140.0
	move_and_slide()
	global_position.x = clampf(global_position.x, 105.0, 1175.0)
	global_position.y = clampf(global_position.y, 125.0, 645.0)

	# Global combat hooks
	GameManager.boss_hit.emit(dmg, is_crit, attacker, hit_pos)
	GameManager.record_damage(attacker, dmg)
	GameManager.play_sound("monster_hit")

	# Hit flash & knockback lean
	var flinch_tween = create_tween()
	sprite.modulate = Color(2.8, 0.4, 0.4)
	flinch_tween.tween_property(sprite, "modulate", Color.WHITE, 0.16)

	if current_health <= 0.0:
		_die()

func _die() -> void:
	is_dead = true
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	hp_bar.visible = false
	name_label.visible = false
	GameManager.play_sound("monster_die")

	# Drop items according to loot table
	var cfg = MONSTER_CONFIGS.get(monster_type, MONSTER_CONFIGS["skeleton"])
	var loot_table = cfg.get("loot", [])
	for item_entry in loot_table:
		if randf() <= item_entry["chance"]:
			var amt = randi_range(item_entry["min"], item_entry["max"])
			var offset = Vector2(randf_range(-24, 24), randf_range(-24, 24))
			GameManager.item_dropped.emit(item_entry["id"], amt, global_position + offset)

	# Death fade & queue free
	var t = create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, 0.35)
	t.parallel().tween_property(sprite, "scale", Vector2(0.3, 0.3), 0.35)
	t.tween_callback(queue_free)
