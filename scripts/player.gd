extends CharacterBody2D

# Universal LPC Hero controller with 4-directional animations, responsive WASD/Mouse combat, 3-hit manual combo, and 6 active skills

signal stats_updated()
signal inventory_changed()
signal health_changed(current: float, max_val: float)
signal mana_changed(current: float, max_val: float)
signal skills_updated(cd_q_ratio: float, cd_e_ratio: float, cd_r_ratio: float, cd_dash_ratio: float, cd_f_ratio: float, cd_space_ratio: float)

# Authentic LPC Spritesheets (64x64 grid, 4 directions: 0=Up, 1=Left, 2=Down, 3=Right)
const TEX_WALK = preload("res://assets/characters/player_lpc/walk.png")
const TEX_SLASH = preload("res://assets/characters/player_lpc/slash.png")
const TEX_THRUST = preload("res://assets/characters/player_lpc/thrust.png")
const TEX_SPELLCAST = preload("res://assets/characters/player_lpc/spellcast.png")
const TEX_HURT = preload("res://assets/characters/player_lpc/hurt.png")

# Real FX Assets
const TEX_SLASH_1 = preload("res://assets/fx/slash_arc_1.png")
const TEX_SLASH_2 = preload("res://assets/fx/slash_arc_2.png")
const TEX_SLASH_HEAVY = preload("res://assets/fx/slash_heavy.png")
const TEX_WHIRLWIND = preload("res://assets/fx/fx_whirlwind.png")
const TEX_VOID_LANCE = preload("res://assets/fx/fx_void_lance.png")
const TEX_CELESTIAL_SWORD = preload("res://assets/fx/fx_celestial_sword.png")
const TEX_CRATER = preload("res://assets/fx/fx_crater.png")
const TEX_SPARK = preload("res://assets/fx/fx_hit_spark.png")
const TEX_MAGIC_SIGIL = preload("res://assets/fx/fx_magic_sigil.png")
const TEX_SHOCKWAVE = preload("res://assets/fx/fx_shockwave.png")
const TEX_HOLY_SHIELD = preload("res://assets/fx/fx_holy_shield.png")
const TEX_LIGHTNING = preload("res://assets/fx/fx_lightning_bolt.png")
const FLOATING_TEXT = preload("res://scenes/floating_text.tscn")

@export var move_speed: float = 320.0
@export var player_id: String = "player_hero"

var hud_ref: Node = null

var max_health: float = 1200.0
var current_health: float = 1200.0
var max_mana: float = 120.0
var current_mana: float = 120.0
var base_mana_regen: float = 12.0

# Skill MP Costs
const COST_DASH: float = 6.0
const COST_WHIRLWIND: float = 18.0
const COST_VOID_PIERCER: float = 20.0
const COST_STARFALL: float = 40.0
const COST_DIVINE_AEGIS: float = 25.0
const COST_THUNDER_TEMPEST: float = 35.0

# Equipment Limits & Caps
const MAX_BAG_SLOTS: int = 20
const MAX_UPGRADE_LEVEL: int = 10

var equipped_weapon: String = "wpn_sword_1"
var weapon_upgrade: int = 0
var equipped_armor: String = "arm_leather_1"
var armor_upgrade: int = 0
var equipped_ring: String = "ring_copper_1"

# Animation & Direction state (0: Up, 1: Left, 2: Down, 3: Right)
var current_row: int = 2
var walk_anim_time: float = 0.0
var is_attacking: bool = false
var is_anim_skill: bool = false

# Combat combo state
var combo_step: int = 0
var combo_reset_timer: float = 0.0
var attack_cooldown: float = 0.0

# Dodge dash mechanics
var dash_speed: float = 720.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var max_dash_cd: float = 0.35
var invulnerable_timer: float = 0.0

# Active Skills Cooldowns
var cd_q: float = 0.0
var max_cd_q: float = 2.2
var cd_e: float = 0.0
var max_cd_e: float = 2.0
var cd_r: float = 0.0
var max_cd_r: float = 6.0
var cd_f: float = 0.0
var max_cd_f: float = 7.0
var cd_space: float = 0.0
var max_cd_space: float = 4.5

# Skill F: Divine Aegis state
var aegis_timer: float = 0.0
var aegis_node: Sprite2D = null

# Equipment & Inventory
var inventory: Dictionary = {}
var boss_target: Node2D = null

@onready var visual_root: Node2D = $VisualRoot
@onready var sprite: Sprite2D = $VisualRoot/Sprite2D
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	add_to_group("players")
	inventory["wpn_sword_1"] = 1
	inventory["arm_leather_1"] = 1
	inventory["ring_copper_1"] = 1
	name_label.text = Localization.tr_text("player_name")
	GameManager.item_collected.connect(_on_loot_collected)
	
	sprite.texture = TEX_WALK
	sprite.hframes = 9
	sprite.vframes = 4
	sprite.frame = current_row * 9 + 0

	_update_derived_stats()
	current_health = max_health
	current_mana = max_mana
	health_changed.emit(current_health, max_health)
	mana_changed.emit(current_mana, max_mana)
	stats_updated.emit()

func _physics_process(delta: float) -> void:
	# Cooldown timers
	if dash_cooldown > 0.0: dash_cooldown -= delta
	if cd_q > 0.0: cd_q -= delta
	if cd_e > 0.0: cd_e -= delta
	if cd_r > 0.0: cd_r -= delta
	if cd_f > 0.0: cd_f -= delta
	if cd_space > 0.0: cd_space -= delta
	if attack_cooldown > 0.0: attack_cooldown -= delta

	if combo_reset_timer > 0.0:
		combo_reset_timer -= delta
		if combo_reset_timer <= 0.0:
			combo_step = 0

	# Divine Aegis active duration
	if aegis_timer > 0.0:
		aegis_timer -= delta
		if aegis_node and is_instance_valid(aegis_node):
			aegis_node.rotation += delta * 2.8
		if aegis_timer <= 0.0:
			_end_divine_aegis()

	# Emit HUD cooldown ratios
	skills_updated.emit(
		clamp(cd_q / max_cd_q, 0.0, 1.0),
		clamp(cd_e / max_cd_e, 0.0, 1.0),
		clamp(cd_r / max_cd_r, 0.0, 1.0),
		clamp(dash_cooldown / max_dash_cd, 0.0, 1.0),
		clamp(cd_f / max_cd_f, 0.0, 1.0),
		clamp(cd_space / max_cd_space, 0.0, 1.0)
	)

	# Invulnerability flash
	if invulnerable_timer > 0.0 and aegis_timer <= 0.0:
		invulnerable_timer -= delta
		visual_root.modulate.a = 0.55
	else:
		visual_root.modulate.a = 1.0

	# Dash execution
	if is_dashing:
		dash_timer -= delta
		if fmod(dash_timer, 0.05) < delta:
			_spawn_dash_ghost(Color(0.4, 0.85, 1.0, 0.5))
		move_and_slide()
		global_position.x = clampf(global_position.x, 105.0, 1175.0)
		global_position.y = clampf(global_position.y, 125.0, 645.0)
		if dash_timer <= 0.0:
			is_dashing = false
			_set_lpc_texture(TEX_WALK, 9, 4)
		return

	# Block gameplay inputs if UI modal or title screen is active
	if is_ui_blocked():
		velocity = Vector2.ZERO
		move_and_slide()
		if not is_attacking:
			_set_lpc_texture(TEX_WALK, 9, 4)
			sprite.frame = current_row * 9 + 0
		return

	# Responsive movement input (WASD + Arrow Keys)
	var move_input = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		move_input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		move_input.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		move_input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		move_input.x += 1.0

	var move_dir = move_input.normalized()

	# Dodge Dash input (Spacebar or Shift) - cancels melee attack instantly
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_SHIFT)) and dash_cooldown <= 0.0 and not is_dashing:
		is_attacking = false
		is_anim_skill = false
		var target_dash = move_dir if move_dir != Vector2.ZERO else _get_facing_vector()
		_perform_dash(target_dash)
		return

	# Skill inputs (1, 2, 3, 4, 5 + Q, E, R, F)
	if (Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_Q) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)) and cd_q <= 0.0 and not is_anim_skill:
		is_attacking = false
		cast_whirlwind()
		return
	elif (Input.is_key_pressed(KEY_2) or Input.is_key_pressed(KEY_E)) and cd_e <= 0.0 and not is_anim_skill:
		is_attacking = false
		var to_mouse = (get_global_mouse_position() - global_position).normalized()
		var aim = to_mouse if to_mouse.length() > 0.1 else (move_dir if move_dir != Vector2.ZERO else _get_facing_vector())
		cast_void_piercer(aim)
		return
	elif (Input.is_key_pressed(KEY_3) or Input.is_key_pressed(KEY_R)) and cd_r <= 0.0 and not is_anim_skill:
		is_attacking = false
		cast_starfall_ultimate()
		return
	elif (Input.is_key_pressed(KEY_4) or Input.is_key_pressed(KEY_F)) and cd_f <= 0.0 and not is_anim_skill:
		is_attacking = false
		cast_divine_aegis()
		return
	elif Input.is_key_pressed(KEY_5) and cd_space <= 0.0 and not is_anim_skill:
		is_attacking = false
		cast_thunder_tempest()
		return

	# Manual Left-Click Combo Attack
	var wants_attack = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_J)
	if wants_attack and not is_attacking and not is_anim_skill and attack_cooldown <= 0.0:
		var aim_dir = (get_global_mouse_position() - global_position).normalized()
		_perform_combo_attack(aim_dir)

	# Movement execution (allows 75% speed movement while swinging weapon)
	if not is_anim_skill:
		var current_speed = move_speed if not is_attacking else move_speed * 0.75
		velocity = move_dir * current_speed
		move_and_slide()
		global_position.x = clampf(global_position.x, 105.0, 1175.0)
		global_position.y = clampf(global_position.y, 125.0, 645.0)

		# Update facing row and walk animation
		if not is_attacking:
			if move_dir != Vector2.ZERO:
				_update_facing_from_vector(move_dir)
				_set_lpc_texture(TEX_WALK, 9, 4)
				walk_anim_time += delta * 12.0
				var frame_col = (int(walk_anim_time) % 8) + 1 # Frames 1..8 are walk
				sprite.frame = current_row * 9 + frame_col
			else:
				walk_anim_time = 0.0
				_set_lpc_texture(TEX_WALK, 9, 4)
				sprite.frame = current_row * 9 + 0 # Frame 0 is idle
	else:
		# Skills allow drift
		move_and_slide()

	# Passive health & mana regeneration
	if current_health < max_health:
		current_health = min(max_health, current_health + delta * 15.0)
		health_changed.emit(current_health, max_health)
	if current_mana < max_mana:
		current_mana = min(max_mana, current_mana + delta * get_total_mp_regen())
		mana_changed.emit(current_mana, max_mana)

func _update_derived_stats() -> void:
	var prev_max_hp = max_health
	var prev_max_mp = max_mana

	max_health = get_total_max_health()
	max_mana = get_total_max_mana()

	if prev_max_hp > 0.0 and max_health != prev_max_hp:
		current_health = clampf(current_health, 0.0, max_health)
	if prev_max_mp > 0.0 and max_mana != prev_max_mp:
		current_mana = clampf(current_mana, 0.0, max_mana)

	health_changed.emit(current_health, max_health)
	mana_changed.emit(current_mana, max_mana)

func is_ui_blocked() -> bool:
	if hud_ref and is_instance_valid(hud_ref) and hud_ref.has_method("is_ui_blocking"):
		return hud_ref.is_ui_blocking()
	return false

func get_total_max_health() -> float:
	var bonus = 0.0
	if equipped_armor != "":
		var arm = ItemsDatabase.ITEMS.get(equipped_armor, {})
		bonus += arm.get("hp_bonus", 0.0)
	bonus += armor_upgrade * 40.0
	return 1200.0 + bonus

func get_total_max_mana() -> float:
	var bonus = 0.0
	if equipped_ring != "":
		var ring = ItemsDatabase.ITEMS.get(equipped_ring, {})
		bonus += ring.get("mp_bonus", 0.0)
	return 120.0 + bonus

func get_total_mp_regen() -> float:
	var bonus = 0.0
	if equipped_ring != "":
		var ring = ItemsDatabase.ITEMS.get(equipped_ring, {})
		bonus += ring.get("mp_regen", 0.0)
	return base_mana_regen + bonus

func get_total_defense() -> float:
	var def = 0.0
	if equipped_armor != "":
		var arm = ItemsDatabase.ITEMS.get(equipped_armor, {})
		def += arm.get("def", 0.0)
	def += armor_upgrade * 0.02
	return clampf(def, 0.0, 0.75)

func get_total_crit_chance() -> float:
	var crit = 0.15
	if equipped_ring != "":
		var ring = ItemsDatabase.ITEMS.get(equipped_ring, {})
		crit += ring.get("crit", 0.0)
	return clampf(crit, 0.0, 0.85)

func _update_facing_from_vector(v: Vector2) -> void:
	if abs(v.x) > abs(v.y):
		current_row = 3 if v.x > 0 else 1
	else:
		current_row = 2 if v.y > 0 else 0

func _get_facing_vector() -> Vector2:
	match current_row:
		0: return Vector2.UP
		1: return Vector2.LEFT
		2: return Vector2.DOWN
		3: return Vector2.RIGHT
	return Vector2.DOWN

func _set_lpc_texture(tex: Texture2D, hf: int, vf: int) -> void:
	if sprite.texture != tex:
		sprite.texture = tex
		sprite.hframes = hf
		sprite.vframes = vf

func _perform_dash(dir: Vector2) -> void:
	if current_mana < COST_DASH:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_DASH
	mana_changed.emit(current_mana, max_mana)

	is_dashing = true
	dash_timer = 0.24
	dash_cooldown = max_dash_cd
	invulnerable_timer = 0.28
	velocity = dir.normalized() * dash_speed
	_update_facing_from_vector(dir)
	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 1
	_spawn_dash_ghost(Color(0.35, 0.8, 1.0, 0.75))
	GameManager.play_sound("dash")

func _spawn_dash_ghost(tint: Color) -> void:
	var ghost = Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.global_position = sprite.global_position
	ghost.scale = visual_root.scale
	ghost.modulate = tint
	get_parent().add_child(ghost)
	var t = create_tween()
	t.tween_property(ghost, "modulate:a", 0.0, 0.22)
	t.tween_callback(ghost.queue_free)

# --- 3-HIT RESPONSIVE COMBO ATTACK (AUTHENTIC LPC SLASH & THRUST) ---
func _perform_combo_attack(aim_dir: Vector2) -> void:
	is_attacking = true
	_update_facing_from_vector(aim_dir)
	combo_reset_timer = 0.95
	attack_cooldown = 0.28

	var step = combo_step
	combo_step = (combo_step + 1) % 3

	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)
	var is_crit = randf() < get_total_crit_chance()

	match step:
		0:
			# Hit 1: Downward Slash (LPC slash.png: 6 frames)
			_set_lpc_texture(TEX_SLASH, 6, 4)
			for f in range(6):
				sprite.frame = current_row * 6 + f
				if f == 3: # Apex hit frame
					_execute_melee_hit(base_dmg, is_crit, 110.0, aim_dir, TEX_SLASH_1)
					GameManager.play_sound("sword_slash")
					GameManager.trigger_screen_shake(3.0, 0.1)
				await get_tree().create_timer(0.04).timeout

		1:
			# Hit 2: Upward Backhand Slash (LPC slash.png: 6 frames)
			_set_lpc_texture(TEX_SLASH, 6, 4)
			for f in range(6):
				sprite.frame = current_row * 6 + f
				if f == 3: # Apex hit frame
					_execute_melee_hit(base_dmg * 1.35, is_crit or randf() < 0.25, 120.0, aim_dir, TEX_SLASH_2)
					GameManager.play_sound("sword_slash")
					GameManager.trigger_screen_shake(4.5, 0.12)
				await get_tree().create_timer(0.04).timeout

		2:
			# Hit 3: Finisher Thrust Cleave (LPC thrust.png: 8 frames)
			_set_lpc_texture(TEX_THRUST, 8, 4)
			velocity = aim_dir * 180.0 # Forward step surge
			for f in range(8):
				sprite.frame = current_row * 8 + f
				if f == 4: # Apex thrust impact frame
					_execute_melee_hit(base_dmg * 2.2, true, 145.0, aim_dir, TEX_SLASH_HEAVY)
					GameManager.play_sound("sword_slash")
					GameManager.trigger_screen_shake(7.5, 0.18)
					_spawn_hit_sparks(global_position + aim_dir * 45.0)
				await get_tree().create_timer(0.038).timeout
			velocity = Vector2.ZERO

	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 0
	is_attacking = false

func _execute_melee_hit(dmg: float, crit: bool, hit_range: float, aim_dir: Vector2, arc_tex: Texture2D) -> void:
	# Spawn visual slash arc in front of player
	var arc = Sprite2D.new()
	arc.texture = arc_tex
	arc.position = aim_dir * 32.0
	arc.rotation = aim_dir.angle()
	arc.scale = Vector2(1.15, 1.15)
	visual_root.add_child(arc)
	var t = create_tween()
	t.tween_property(arc, "scale", Vector2(1.4, 1.4), 0.14)
	t.parallel().tween_property(arc, "modulate:a", 0.0, 0.14)
	t.tween_callback(arc.queue_free)

	var hit_count = 0
	var enemies = _get_all_enemies()
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			var to_enemy = e.global_position - global_position
			var dist = to_enemy.length()
			if dist <= hit_range:
				# Cone check (approx 130 degrees)
				var dot = aim_dir.dot(to_enemy.normalized())
				if dot >= 0.25 or dist <= 48.0:
					e.take_damage(dmg, crit, player_id, e.global_position)
					_spawn_hit_sparks(e.global_position)
					hit_count += 1

	if hit_count > 0:
		current_mana = min(max_mana, current_mana + 15.0)
		mana_changed.emit(current_mana, max_mana)

func _get_all_enemies() -> Array:
	var enemies: Array = []
	_find_boss()
	if boss_target and is_instance_valid(boss_target):
		enemies.append(boss_target)
	var mobs = get_tree().get_nodes_in_group("monsters")
	for m in mobs:
		if is_instance_valid(m) and not (m in enemies) and not m.get("is_dead"):
			enemies.append(m)
	return enemies

func _find_boss() -> void:
	if not boss_target or not is_instance_valid(boss_target):
		var bosses = get_tree().get_nodes_in_group("boss")
		if bosses.size() > 0:
			boss_target = bosses[0]

func _spawn_hit_sparks(pos: Vector2) -> void:
	for i in range(4):
		var sp = Sprite2D.new()
		sp.texture = TEX_SPARK
		sp.global_position = pos + Vector2(randf_range(-18, 18), randf_range(-18, 18))
		sp.scale = Vector2(randf_range(0.5, 0.8), randf_range(0.5, 0.8))
		get_parent().add_child(sp)
		var t = create_tween()
		t.tween_property(sp, "scale", Vector2(1.1, 1.1), 0.14)
		t.parallel().tween_property(sp, "modulate:a", 0.0, 0.14)
		t.tween_callback(sp.queue_free)

# --- SKILL 1: WHIRLWIND [Q] (360 SPINNING SLASH VORTEX) ---
func cast_whirlwind() -> void:
	if current_mana < COST_WHIRLWIND:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_WHIRLWIND
	mana_changed.emit(current_mana, max_mana)

	cd_q = max_cd_q
	is_anim_skill = true
	GameManager.play_sound("sword_slash")
	GameManager.trigger_screen_shake(6.0, 0.3)

	var vortex = Sprite2D.new()
	vortex.texture = TEX_WHIRLWIND
	vortex.position = Vector2(0, 10)
	vortex.scale = Vector2(0.4, 0.4)
	vortex.modulate = Color(1.2, 1.5, 2.0, 0.9)
	visual_root.add_child(vortex)

	var vt = create_tween()
	vt.tween_property(vortex, "scale", Vector2(1.5, 1.5), 0.18)
	vt.parallel().tween_property(vortex, "rotation", TAU * 3.0, 0.5)
	vt.tween_property(vortex, "modulate:a", 0.0, 0.15)
	vt.tween_callback(vortex.queue_free)

	_set_lpc_texture(TEX_SLASH, 6, 4)
	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)

	# Spin through all 4 directions 3 times
	for spin in range(3):
		for r in [2, 1, 0, 3]:
			current_row = r
			sprite.frame = current_row * 6 + 3
			var enemies = _get_all_enemies()
			for e in enemies:
				if is_instance_valid(e) and not e.get("is_dead") and global_position.distance_to(e.global_position) <= 175.0:
					e.take_damage(base_dmg * 0.65, randf() < 0.2, player_id, e.global_position)
			await get_tree().create_timer(0.04).timeout

	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 0
	is_anim_skill = false

# --- SKILL 2: VOID PIERCER [E] (FORWARD VOID LANCE DASH) ---
func cast_void_piercer(target_dir: Vector2) -> void:
	if current_mana < COST_VOID_PIERCER:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_VOID_PIERCER
	mana_changed.emit(current_mana, max_mana)

	cd_e = max_cd_e
	is_anim_skill = true
	_update_facing_from_vector(target_dir)

	_set_lpc_texture(TEX_THRUST, 8, 4)
	sprite.frame = current_row * 8 + 4

	var dash_dist = 220.0
	var start_pos = global_position
	var end_pos = global_position + target_dir * dash_dist

	var lance = Sprite2D.new()
	lance.texture = TEX_VOID_LANCE
	lance.position = target_dir * 110.0
	lance.rotation = target_dir.angle()
	lance.scale = Vector2(0.2, 0.6)
	lance.modulate = Color(1.6, 0.6, 2.5, 0.95)
	visual_root.add_child(lance)

	var lt = create_tween()
	lt.tween_property(lance, "scale", Vector2(1.5, 1.2), 0.12)
	lt.parallel().tween_property(lance, "modulate:a", 0.0, 0.28)
	lt.tween_callback(lance.queue_free)

	invulnerable_timer = 0.3
	GameManager.play_sound("sword_slash")
	GameManager.trigger_screen_shake(8.0, 0.25)

	# Instant phantom dash forward
	var move_tw = create_tween()
	move_tw.tween_property(self, "global_position", end_pos, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await move_tw.finished

	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)
	var enemies = _get_all_enemies()
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			if _distance_to_segment(e.global_position, start_pos, end_pos) <= 85.0:
				e.take_damage(base_dmg * 3.0, true, player_id, e.global_position)
				_spawn_hit_sparks(e.global_position)

	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 0
	is_anim_skill = false

# --- SKILL 3: CELESTIAL STARFALL [R] (FALLING SWORD IMPACT) ---
func cast_starfall_ultimate() -> void:
	if current_mana < COST_STARFALL:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_STARFALL
	mana_changed.emit(current_mana, max_mana)

	cd_r = max_cd_r
	is_anim_skill = true
	_find_boss()

	var target_pos = boss_target.global_position if (boss_target and is_instance_valid(boss_target)) else get_global_mouse_position()

	# Chanting pose (spellcast.png)
	_set_lpc_texture(TEX_SPELLCAST, 7, 4)
	current_row = 2
	for f in range(5):
		sprite.frame = current_row * 7 + f
		await get_tree().create_timer(0.045).timeout

	visual_root.modulate = Color(2.0, 1.8, 0.8)

	var sigil = Sprite2D.new()
	sigil.texture = TEX_MAGIC_SIGIL
	sigil.global_position = target_pos
	sigil.scale = Vector2(0.2, 0.2)
	sigil.modulate = Color(2.5, 2.0, 0.6, 0.85)
	get_parent().add_child(sigil)

	var st = create_tween()
	st.tween_property(sigil, "scale", Vector2(1.4, 1.4), 0.35)
	st.parallel().tween_property(sigil, "rotation", TAU * 1.5, 0.7)

	await get_tree().create_timer(0.35).timeout

	# Giant celestial sword falls from above
	var sword = Sprite2D.new()
	sword.texture = TEX_CELESTIAL_SWORD
	sword.global_position = target_pos - Vector2(0, 520)
	sword.scale = Vector2(1.6, 1.6)
	sword.modulate = Color(2.5, 2.2, 1.0)
	get_parent().add_child(sword)

	var sw_tw = create_tween()
	sw_tw.tween_property(sword, "global_position:y", target_pos.y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await sw_tw.finished

	GameManager.trigger_screen_shake(16.0, 0.45)
	GameManager.play_sound("crit_hit")

	# Impact crater & shockwave
	var crater = Sprite2D.new()
	crater.texture = TEX_CRATER
	crater.global_position = target_pos
	crater.scale = Vector2(1.4, 1.4)
	get_parent().add_child(crater)

	var wave = Sprite2D.new()
	wave.texture = TEX_SHOCKWAVE
	wave.global_position = target_pos
	wave.scale = Vector2(0.3, 0.3)
	wave.modulate = Color(2.0, 1.8, 0.7)
	get_parent().add_child(wave)

	var wt = create_tween()
	wt.tween_property(wave, "scale", Vector2(2.5, 2.5), 0.32)
	wt.parallel().tween_property(wave, "modulate:a", 0.0, 0.32)
	wt.tween_callback(wave.queue_free)

	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)
	var ult_dmg = base_dmg * 6.0

	var enemies = _get_all_enemies()
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead") and target_pos.distance_to(e.global_position) <= 240.0:
			e.take_damage(ult_dmg, true, player_id, e.global_position)
			_spawn_hit_sparks(e.global_position)

	var sword_fade = create_tween()
	sword_fade.tween_interval(0.4)
	sword_fade.tween_property(sword, "modulate:a", 0.0, 0.3)
	sword_fade.parallel().tween_property(crater, "modulate:a", 0.0, 0.4)
	sword_fade.parallel().tween_property(sigil, "modulate:a", 0.0, 0.3)
	sword_fade.tween_callback(func():
		sword.queue_free()
		crater.queue_free()
		sigil.queue_free()
	)

	visual_root.modulate = Color.WHITE
	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 0
	is_anim_skill = false

# --- SKILL 4: DIVINE AEGIS [F] (INVULNERABILITY SHIELD & BURST HEAL) ---
func cast_divine_aegis() -> void:
	if current_mana < COST_DIVINE_AEGIS:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_DIVINE_AEGIS
	mana_changed.emit(current_mana, max_mana)

	cd_f = max_cd_f
	aegis_timer = 3.5
	invulnerable_timer = 3.5

	GameManager.play_sound("skill_aegis")
	GameManager.trigger_screen_shake(4.0, 0.2)

	if aegis_node and is_instance_valid(aegis_node):
		aegis_node.queue_free()

	aegis_node = Sprite2D.new()
	aegis_node.texture = TEX_HOLY_SHIELD
	aegis_node.position = Vector2.ZERO
	aegis_node.scale = Vector2(0.95, 0.95)
	aegis_node.modulate = Color(2.2, 1.9, 0.9, 0.9)
	visual_root.add_child(aegis_node)

	var pulse = create_tween().set_loops(4)
	pulse.tween_property(aegis_node, "scale", Vector2(1.1, 1.1), 0.42)
	pulse.tween_property(aegis_node, "scale", Vector2(0.95, 0.95), 0.42)

func _end_divine_aegis() -> void:
	aegis_timer = 0.0
	if aegis_node and is_instance_valid(aegis_node):
		var collapse = create_tween()
		collapse.tween_property(aegis_node, "scale", Vector2(1.6, 1.6), 0.15)
		collapse.parallel().tween_property(aegis_node, "modulate:a", 0.0, 0.15)
		collapse.tween_callback(aegis_node.queue_free)
		aegis_node = null

	# Holy burst heal & radial blast
	current_health = min(max_health, current_health + 160.0)
	health_changed.emit(current_health, max_health)
	GameManager.play_sound("crit_hit")

	var enemies = _get_all_enemies()
	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead") and global_position.distance_to(e.global_position) <= 210.0:
			e.take_damage(base_dmg * 2.8, false, player_id, e.global_position)
			_spawn_hit_sparks(e.global_position)

# --- SKILL 5: THUNDER TEMPEST [SPACE] (GLOBAL LIGHTNING STRIKE) ---
func cast_thunder_tempest() -> void:
	if current_mana < COST_THUNDER_TEMPEST:
		GameManager.play_tone(150.0, 0.08, 0.25)
		return
	current_mana -= COST_THUNDER_TEMPEST
	mana_changed.emit(current_mana, max_mana)

	cd_space = max_cd_space
	is_anim_skill = true

	_set_lpc_texture(TEX_SPELLCAST, 7, 4)
	current_row = 2
	sprite.frame = current_row * 7 + 3
	visual_root.modulate = Color(1.2, 2.0, 3.0)

	GameManager.play_sound("skill_lightning")
	GameManager.trigger_screen_shake(12.0, 0.4)
	GameManager.trigger_environment_tint(Color(0.8, 1.3, 2.2), 0.3)

	var enemies = _get_all_enemies()
	var wpn = ItemsDatabase.ITEMS.get(equipped_weapon, {})
	var base_dmg = randf_range(wpn.get("min_atk", 28), wpn.get("max_atk", 44)) * (1.0 + weapon_upgrade * 0.15)
	var thunder_dmg = base_dmg * 3.2

	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			var bolt = Sprite2D.new()
			bolt.texture = TEX_LIGHTNING
			bolt.global_position = e.global_position - Vector2(0, 140)
			bolt.scale = Vector2(1.2, 1.2)
			bolt.modulate = Color(1.5, 2.2, 3.5)
			get_parent().add_child(bolt)

			var bt = create_tween()
			bt.tween_property(bolt, "modulate:a", 0.0, 0.28)
			bt.tween_callback(bolt.queue_free)

			e.take_damage(thunder_dmg, true, player_id, e.global_position)
			_spawn_hit_sparks(e.global_position)

	await get_tree().create_timer(0.25).timeout
	visual_root.modulate = Color.WHITE
	_set_lpc_texture(TEX_WALK, 9, 4)
	sprite.frame = current_row * 9 + 0
	is_anim_skill = false

func take_hit(dmg: float, knockback_dir: Vector2) -> void:
	if invulnerable_timer > 0.0:
		if aegis_timer > 0.0:
			GameManager.play_sound("crit_hit")
			_spawn_hit_sparks(global_position)
		return

	var def = get_total_defense()
	var actual_dmg = max(1.0, dmg * (1.0 - def))
	current_health -= actual_dmg
	velocity = knockback_dir * 280.0
	invulnerable_timer = 0.45
	health_changed.emit(current_health, max_health)
	GameManager.trigger_screen_shake(8.0, 0.2)
	GameManager.play_tone(130.0, 0.15, 0.35)

	# Flinch flash
	var flinch_tween = create_tween()
	sprite.modulate = Color(2.6, 0.4, 0.4)
	flinch_tween.tween_property(sprite, "modulate", Color.WHITE, 0.18)

	if current_health <= 0.0:
		current_health = max_health * 0.5 # Revive with half health to keep fighting
		invulnerable_timer = 1.8 # Generous grace period on revive
		health_changed.emit(current_health, max_health)

func _distance_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ab_len_sq = ab.length_squared()
	if ab_len_sq == 0.0: return p.distance_to(a)
	var t = clamp((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var projection = a + t * ab
	return p.distance_to(projection)

# --- INVENTORY, EQUIPMENT SLOTS, UPGRADE LIMITS & CRAFTING ---
func can_accept_item(item_id: String) -> bool:
	if inventory.has(item_id) and inventory[item_id] > 0:
		return true
	return inventory.keys().size() < MAX_BAG_SLOTS

func _on_loot_collected(item_id: String, amount: int) -> void:
	if item_id == "item_heal_potion" or item_id == "heal_orb":
		var heal_val = 250.0 * amount
		current_health = min(max_health, current_health + heal_val)
		health_changed.emit(current_health, max_health)
		GameManager.play_sound("crit_hit")
		var fl = FLOATING_TEXT.instantiate()
		fl.global_position = global_position + Vector2(0, -32)
		fl.setup("+%d HP" % int(heal_val), Color(0.25, 1.0, 0.45), 1.2)
		get_parent().add_child(fl)
		return

	if not can_accept_item(item_id):
		GameManager.trigger_screen_shake(2.0, 0.1)
		return
	inventory[item_id] = inventory.get(item_id, 0) + amount
	inventory_changed.emit()

func equip_weapon(wpn_id: String) -> void:
	if inventory.get(wpn_id, 0) > 0 and ItemsDatabase.ITEMS.has(wpn_id):
		equipped_weapon = wpn_id
		stats_updated.emit()
		inventory_changed.emit()
		GameManager.play_sound("equip")

func equip_armor(arm_id: String) -> void:
	if inventory.get(arm_id, 0) > 0 and ItemsDatabase.ITEMS.has(arm_id):
		equipped_armor = arm_id
		_update_derived_stats()
		stats_updated.emit()
		inventory_changed.emit()
		GameManager.play_sound("equip")

func equip_ring(ring_id: String) -> void:
	if inventory.get(ring_id, 0) > 0 and ItemsDatabase.ITEMS.has(ring_id):
		equipped_ring = ring_id
		_update_derived_stats()
		stats_updated.emit()
		inventory_changed.emit()
		GameManager.play_sound("equip")

func upgrade_weapon() -> bool:
	if weapon_upgrade >= MAX_UPGRADE_LEVEL:
		return false
	var need_stone = weapon_upgrade + 1
	var need_dust = (weapon_upgrade + 1) * 8
	var need_gem = max(0, weapon_upgrade - 2)

	if inventory.get("mat_stone", 0) >= need_stone and inventory.get("mat_dust", 0) >= need_dust and inventory.get("mat_gem", 0) >= need_gem:
		inventory["mat_stone"] -= need_stone
		inventory["mat_dust"] -= need_dust
		if need_gem > 0: inventory["mat_gem"] -= need_gem
		weapon_upgrade += 1
		inventory_changed.emit()
		stats_updated.emit()
		GameManager.play_sound("craft")
		return true
	return false

func upgrade_armor() -> bool:
	if armor_upgrade >= MAX_UPGRADE_LEVEL:
		return false
	var need_stone = armor_upgrade + 1
	var need_dust = (armor_upgrade + 1) * 6
	var need_gem = max(0, armor_upgrade - 2)

	if inventory.get("mat_stone", 0) >= need_stone and inventory.get("mat_dust", 0) >= need_dust and inventory.get("mat_gem", 0) >= need_gem:
		inventory["mat_stone"] -= need_stone
		inventory["mat_dust"] -= need_dust
		if need_gem > 0: inventory["mat_gem"] -= need_gem
		armor_upgrade += 1
		_update_derived_stats()
		inventory_changed.emit()
		stats_updated.emit()
		GameManager.play_sound("craft")
		return true
	return false

func craft_weapon(wpn_id: String) -> bool:
	return craft_item(wpn_id)

func craft_item(item_id: String) -> bool:
	if not ItemsDatabase.RECIPES.has(item_id): return false
	if not can_accept_item(item_id): return false
	var recipe = ItemsDatabase.RECIPES[item_id]
	var costs = recipe.get("costs", {})

	for mat_id in costs.keys():
		var required = costs[mat_id]
		if inventory.get(mat_id, 0) < required:
			return false

	for mat_id in costs.keys():
		inventory[mat_id] -= costs[mat_id]

	inventory[item_id] = inventory.get(item_id, 0) + 1
	var item_type = ItemsDatabase.ITEMS.get(item_id, {}).get("type", -1)
	if item_type == ItemsDatabase.ItemType.WEAPON:
		equipped_weapon = item_id
	elif item_type == ItemsDatabase.ItemType.ARMOR:
		equipped_armor = item_id
	elif item_type == ItemsDatabase.ItemType.ACCESSORY:
		equipped_ring = item_id

	_update_derived_stats()
	inventory_changed.emit()
	stats_updated.emit()
	GameManager.play_sound("craft")
	return true

func open_chest(chest_id: String) -> bool:
	if inventory.get(chest_id, 0) <= 0:
		return false
	var rewards = ItemsDatabase.open_chest(chest_id)
	var needed_slots = 0
	for r in rewards:
		var item_id = r["id"]
		if not inventory.has(item_id) or inventory[item_id] <= 0:
			needed_slots += 1
	var free_slots = MAX_BAG_SLOTS - inventory.keys().size()
	if inventory.get(chest_id, 0) == 1:
		free_slots += 1
	if needed_slots > free_slots:
		return false

	inventory[chest_id] -= 1
	if inventory[chest_id] <= 0:
		inventory.erase(chest_id)

	for r in rewards:
		var item_id = r["id"]
		var amt = r["amount"]
		inventory[item_id] = inventory.get(item_id, 0) + amt

	inventory_changed.emit()
	stats_updated.emit()
	GameManager.play_sound("chest_open")
	return true

# Headless automated test interface
func _execute_attack_combo(_wpn: Dictionary) -> void:
	_perform_combo_attack(_get_facing_vector())
