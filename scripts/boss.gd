extends CharacterBody2D

# Hardcore multi-skill infinite boss controller (Eternal Void Colossus)
# Dynamic cast animations, squash/stretch, magic runic sigils, afterimages, and multi-cast combos

signal health_changed(current_hp: float, max_hp: float, phase: int)
signal phase_completed(phase: int)

const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")
const TEX_MAGIC_SIGIL = preload("res://assets/fx/fx_magic_sigil.png")
const TEX_VOID_BEAM = preload("res://assets/fx/fx_void_beam.png")
const TEX_CRATER = preload("res://assets/fx/fx_crater.png")
const TEX_METEOR = preload("res://assets/fx/fx_meteor.png")
const TEX_SHOCKWAVE = preload("res://assets/fx/fx_shockwave.png")
const TEX_ENERGY_RING = preload("res://assets/fx/fx_energy_ring.png")
const TEX_LASER_GUIDE = preload("res://assets/fx/fx_laser_guide.png")
const TEX_VORTEX = preload("res://assets/fx/fx_vortex.png")
const TEX_CLEAVE = preload("res://assets/fx/fx_cleave_line.png")
const TEX_SPARK = preload("res://assets/fx/fx_hit_spark.png")
const TEX_EMBER = preload("res://assets/fx/fx_ember.png")

var current_phase: int = 1
var max_phase_hp: float = 18000.0
var current_hp: float = 18000.0
var total_damage: float = 0.0

# Skill rotation state
var warmup_timer: float = 3.0
var skill_timer: float = 0.0
var skill_cooldown: float = 3.5
var is_casting: bool = false
var active_skill_name: String = ""
var aura_pulse: float = 0.0

# Animation state
var anim_locked: bool = false
var anim_jitter: Vector2 = Vector2.ZERO

# Skill 2: Void Beam state
var beam_charging: bool = false
var beam_active: bool = false
var beam_angle: float = 0.0
var beam_target_angle: float = 0.0

# Skill 3: Meteor Storm telegraphs: [{ "pos": Vector2, "radius": float, "timer": float, "max_time": float, "damage": float }]
var active_telegraphs: Array = []

# Skill 4: Gravity Vortex state
var vortex_timer: float = 0.0
var vortex_pos: Vector2 = Vector2(640, 360)

# Skill 5: Shockwave state: [{ "pos": Vector2, "radius": float, "max_radius": float, "speed": float, "damage": float, "hit_players": Array }]
var active_shockwaves: Array = []

# Skill 6: Dimensional Cleave: [{ "start": Vector2, "end": Vector2, "timer": float, "max_time": float, "damage": float, "active_time": float, "width": float, "hit_players": Array }]
var active_cleaves: Array = []

var player_ref: Node2D = null

@onready var rig: Node2D = $Rig
@onready var sprite: Node2D = $Rig
@onready var wing_l_pivot: Node2D = $Rig/LeftWingPivot
@onready var wing_r_pivot: Node2D = $Rig/RightWingPivot
@onready var head_pivot: Node2D = $Rig/HeadPivot
@onready var body_sprite: Sprite2D = $Rig/Body
@onready var void_core: Sprite2D = $Rig/VoidCore
@onready var claw_l_pivot: Node2D = $Rig/LeftClawPivot
@onready var claw_r_pivot: Node2D = $Rig/RightClawPivot
@onready var claw_l_sprite: Sprite2D = $Rig/LeftClawPivot/LeftClaw
@onready var claw_r_sprite: Sprite2D = $Rig/RightClawPivot/RightClaw
@onready var wing_l_sprite: Sprite2D = $Rig/LeftWingPivot/LeftWing
@onready var wing_r_sprite: Sprite2D = $Rig/RightWingPivot/RightWing
@onready var head_sprite: Sprite2D = $Rig/HeadPivot/Head

var base_boss_tex: Texture2D = preload("res://assets/boss.png")

enum BossAnim { IDLE, FLY, ROAR, SLAM, CHANNEL, SPRAY, FLINCH, COLLAPSE }
var current_anim: BossAnim = BossAnim.IDLE
var anim_time: float = 0.0
var flinch_timer: float = 0.0

var sigil_sprite: Sprite2D = null
var beam_sprite: Sprite2D = null
var laser_guide: Sprite2D = null
var orbiting_embers: Array = []

func _ready() -> void:
	health_changed.emit(current_hp, max_phase_hp, current_phase)
	_setup_boss_fx_nodes()

func _setup_boss_fx_nodes() -> void:
	sigil_sprite = Sprite2D.new()
	sigil_sprite.texture = TEX_MAGIC_SIGIL
	sigil_sprite.scale = Vector2(0.9, 0.9)
	sigil_sprite.visible = false
	add_child(sigil_sprite)

	laser_guide = Sprite2D.new()
	laser_guide.texture = TEX_LASER_GUIDE
	laser_guide.centered = false
	laser_guide.offset = Vector2(0, -8)
	laser_guide.visible = false
	add_child(laser_guide)

	beam_sprite = Sprite2D.new()
	beam_sprite.texture = TEX_VOID_BEAM
	beam_sprite.centered = false
	beam_sprite.offset = Vector2(0, -24)
	beam_sprite.visible = false
	add_child(beam_sprite)

	for i in range(6):
		var emb = Sprite2D.new()
		emb.texture = TEX_EMBER
		emb.scale = Vector2(0.65, 0.65)
		add_child(emb)
		orbiting_embers.append(emb)

func take_damage(damage: float, is_crit: bool, attacker: String, hit_pos: Vector2) -> void:
	var prev_damage = total_damage
	current_hp -= damage
	total_damage += damage

	GameManager.record_damage(attacker, damage)
	GameManager.boss_hit.emit(damage, is_crit, attacker, hit_pos)

	# Calculate loot drop chances based on hit damage
	var drops = ItemsDatabase.calculate_hit_loot(damage, is_crit)
	for d in drops:
		var offset = Vector2(randf_range(-60, 60), randf_range(20, 80))
		GameManager.item_dropped.emit(d["id"], d["amount"], global_position + offset)

	# Check milestone chests
	var chests = ItemsDatabase.check_milestone_chests(prev_damage, total_damage)
	for c in chests:
		var offset = Vector2(randf_range(-80, 80), randf_range(40, 100))
		GameManager.item_dropped.emit(c, 1, global_position + offset)

	# Drop healing potions at 75%, 50%, 25% phase HP milestones
	var prev_ratio = (current_hp + damage) / max_phase_hp
	var curr_ratio = current_hp / max_phase_hp
	for threshold in [0.75, 0.50, 0.25]:
		if prev_ratio >= threshold and curr_ratio < threshold:
			for i in range(2):
				var offset = Vector2(randf_range(-90, 90), randf_range(30, 90))
				GameManager.item_dropped.emit("item_heal_potion", 1, global_position + offset)

	# Flinch stagger & damage flash
	if not anim_locked:
		if is_crit:
			current_anim = BossAnim.FLINCH
			flinch_timer = 0.2
			var knock_dir = (global_position - hit_pos).normalized()
			anim_jitter = knock_dir * 14.0
			var stagger = create_tween()
			stagger.tween_property(self, "anim_jitter", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_ELASTIC)
			sprite.modulate = Color(3.0, 3.2, 4.0)
			var flash = create_tween()
			flash.tween_property(sprite, "modulate", Color.WHITE, 0.1)
			_spawn_hit_spark_fx(hit_pos)
		else:
			sprite.modulate = Color(2.5, 1.2, 1.2)
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)

	health_changed.emit(current_hp, max_phase_hp, current_phase)

	if current_hp <= 0.0:
		_advance_phase()

func _advance_phase() -> void:
	phase_completed.emit(current_phase)
	GameManager.boss_phase_broken.emit(current_phase)
	GameManager.play_sound("phase_break")
	GameManager.trigger_screen_shake(24.0, 0.6)
	GameManager.trigger_environment_tint(Color(1.4, 1.2, 0.6), 0.5)

	# Phase break explosive reaction animation
	current_anim = BossAnim.COLLAPSE
	anim_locked = true
	var break_tween = create_tween()
	break_tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15)
	break_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	_spawn_afterimage(Color(1.0, 0.8, 0.2, 0.8), 0.4)

	# Burst drops on phase break
	for i in range(7):
		var bonus_items = ["mat_shard", "mat_stone", "mat_gem", "chest_mythic", "chest_gold"]
		var id = bonus_items[randi() % bonus_items.size()]
		var offset = Vector2(randf_range(-140, 140), randf_range(30, 140))
		GameManager.item_dropped.emit(id, 1, global_position + offset)

	current_phase += 1
	max_phase_hp = 18000.0 * pow(1.5, current_phase - 1)
	current_hp = max_phase_hp
	skill_cooldown = max(1.4, 3.0 - (current_phase * 0.35))
	health_changed.emit(current_hp, max_phase_hp, current_phase)
	current_anim = BossAnim.IDLE
	anim_locked = false

func _physics_process(delta: float) -> void:
	if not player_ref:
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0: player_ref = players[0]

	aura_pulse += delta * (2.5 + current_phase * 0.6)
	anim_time += delta

	if flinch_timer > 0.0:
		flinch_timer -= delta
		if flinch_timer <= 0.0 and current_anim == BossAnim.FLINCH:
			current_anim = BossAnim.IDLE

	# Articulated skeletal rig procedural animation
	if not anim_locked:
		var hover_y = sin(anim_time * 2.8) * 6.0
		var breath_x = 1.0 + sin(anim_time * 2.5) * 0.03
		var breath_y = 1.0 - sin(anim_time * 2.5) * 0.03
		rig.position = Vector2(0.0, hover_y) + anim_jitter
		rig.scale = Vector2(breath_x, breath_y)

		# Procedural lean towards player
		if player_ref and is_instance_valid(player_ref):
			var to_target = player_ref.global_position - global_position
			var lean = clampf(to_target.x * 0.0003, -0.12, 0.12)
			rig.rotation = lerpf(rig.rotation, lean, delta * 5.0)

		# Pulse BossLight dynamically
		var boss_light = get_node_or_null("BossLight")
		if boss_light:
			boss_light.energy = 1.6 + sin(anim_time * 4.0) * 0.3 + (0.7 if is_casting else 0.0)

		# Void Core continuous swirling & pulsing
		if void_core:
			void_core.rotation += delta * (10.0 if is_casting else 2.6)
			var core_pulse = 1.0 + sin(anim_time * 5.0) * 0.14
			void_core.scale = Vector2(0.85, 0.85) * (core_pulse * (1.3 if is_casting else 1.0))
			var glow_val = 1.0 + sin(anim_time * 6.0) * 0.28
			void_core.modulate = Color(1.2 * glow_val, 0.8 * glow_val, 2.4 * glow_val, 0.95)

		match current_anim:
			BossAnim.IDLE:
				var flap_spd = 6.0 if is_casting else 3.2
				var flap_amp = 0.35 if is_casting else 0.24
				wing_l_pivot.rotation = sin(anim_time * flap_spd) * flap_amp
				wing_r_pivot.rotation = -sin(anim_time * flap_spd) * flap_amp
				head_pivot.rotation = sin(anim_time * 1.8) * 0.06
				head_pivot.scale = Vector2(1.0 + sin(anim_time * 2.5) * 0.03, 1.0 - sin(anim_time * 2.5) * 0.03)
				head_pivot.position = Vector2(0, -45)
				claw_l_pivot.rotation = sin(anim_time * 2.2) * 0.16
				claw_r_pivot.rotation = -sin(anim_time * 2.2) * 0.16
				claw_l_pivot.position = Vector2(-65 + sin(anim_time * 1.8) * 4.0, 15)
				claw_r_pivot.position = Vector2(65 - sin(anim_time * 1.8) * 4.0, 15)

			BossAnim.FLY:
				wing_l_pivot.rotation = sin(anim_time * 8.5) * 0.45
				wing_r_pivot.rotation = -sin(anim_time * 8.5) * 0.45
				head_pivot.rotation = sin(anim_time * 6.0) * 0.12
				head_pivot.scale = Vector2.ONE
				head_pivot.position = Vector2(0, -45 + sin(anim_time * 8.5) * 4.0)
				claw_l_pivot.rotation = -0.35 + sin(anim_time * 7.5) * 0.25
				claw_r_pivot.rotation = 0.35 - sin(anim_time * 7.5) * 0.25
				claw_l_pivot.position = Vector2(-70, 10)
				claw_r_pivot.position = Vector2(70, 10)

			BossAnim.ROAR:
				wing_l_pivot.rotation = -0.55
				wing_r_pivot.rotation = 0.55
				head_pivot.rotation = -0.22
				head_pivot.scale = Vector2(1.25, 1.35)
				head_pivot.position = Vector2(0, -52)
				claw_l_pivot.rotation = -0.75
				claw_r_pivot.rotation = 0.75
				claw_l_pivot.position = Vector2(-85, 5)
				claw_r_pivot.position = Vector2(85, 5)

			BossAnim.SLAM:
				wing_l_pivot.rotation = 0.65
				wing_r_pivot.rotation = -0.65
				head_pivot.rotation = 0.15
				head_pivot.scale = Vector2(1.1, 0.9)
				head_pivot.position = Vector2(0, -42)
				claw_l_pivot.rotation = 0.85
				claw_r_pivot.rotation = -0.85
				claw_l_pivot.position = Vector2(-50, 32)
				claw_r_pivot.position = Vector2(50, 32)

			BossAnim.CHANNEL:
				wing_l_pivot.rotation = -0.35 + sin(anim_time * 20.0) * 0.04
				wing_r_pivot.rotation = 0.35 - sin(anim_time * 20.0) * 0.04
				head_pivot.rotation = 0.15
				head_pivot.scale = Vector2(0.95, 0.95)
				head_pivot.position = Vector2(0, -40)
				claw_l_pivot.rotation = 0.45 + sin(anim_time * 16.0) * 0.12
				claw_r_pivot.rotation = -0.45 - sin(anim_time * 16.0) * 0.12
				claw_l_pivot.position = Vector2(-50, 12)
				claw_r_pivot.position = Vector2(50, 12)

			BossAnim.SPRAY:
				wing_l_pivot.rotation = sin(anim_time * 15.0) * 0.15
				wing_r_pivot.rotation = -sin(anim_time * 15.0) * 0.15
				head_pivot.rotation = sin(anim_time * 22.0) * 0.12
				head_pivot.scale = Vector2(1.15, 1.0)
				head_pivot.position = Vector2(0, -45 + sin(anim_time * 24.0) * 7.0)
				claw_l_pivot.rotation = sin(anim_time * 18.0) * 0.35
				claw_r_pivot.rotation = -sin(anim_time * 18.0) * 0.35

			BossAnim.FLINCH:
				wing_l_pivot.rotation = -0.45
				wing_r_pivot.rotation = 0.45
				head_pivot.rotation = -0.35
				head_pivot.scale = Vector2(1.15, 0.85)
				head_pivot.position = Vector2(0, -54)
				claw_l_pivot.rotation = -0.6
				claw_r_pivot.rotation = 0.6
				claw_l_pivot.position = Vector2(-75, 5)
				claw_r_pivot.position = Vector2(75, 5)

			BossAnim.COLLAPSE:
				wing_l_pivot.rotation = 0.75
				wing_r_pivot.rotation = -0.75
				head_pivot.rotation = 0.4
				head_pivot.scale = Vector2(0.85, 0.85)
				head_pivot.position = Vector2(0, -32)
				claw_l_pivot.rotation = 0.95
				claw_r_pivot.rotation = -0.95
				claw_l_pivot.position = Vector2(-40, 40)
				claw_r_pivot.position = Vector2(40, 40)
	else:
		rig.position += anim_jitter
		if void_core:
			void_core.rotation += delta * 12.0
		match current_anim:
			BossAnim.ROAR:
				wing_l_pivot.rotation = -0.55
				wing_r_pivot.rotation = 0.55
				head_pivot.rotation = -0.22
				head_pivot.scale = Vector2(1.25, 1.35)
				claw_l_pivot.rotation = -0.75
				claw_r_pivot.rotation = 0.75
			BossAnim.SLAM:
				wing_l_pivot.rotation = 0.65
				wing_r_pivot.rotation = -0.65
				claw_l_pivot.rotation = 0.85
				claw_r_pivot.rotation = -0.85
			BossAnim.CHANNEL:
				wing_l_pivot.rotation = -0.35 + sin(anim_time * 20.0) * 0.04
				wing_r_pivot.rotation = 0.35 - sin(anim_time * 20.0) * 0.04
				claw_l_pivot.rotation = 0.45 + sin(anim_time * 16.0) * 0.12
				claw_r_pivot.rotation = -0.45 - sin(anim_time * 16.0) * 0.12
			BossAnim.SPRAY:
				head_pivot.position = Vector2(0, -45 + sin(anim_time * 24.0) * 7.0)
				claw_l_pivot.rotation = sin(anim_time * 18.0) * 0.35
				claw_r_pivot.rotation = -sin(anim_time * 18.0) * 0.35
			BossAnim.FLY:
				wing_l_pivot.rotation = sin(anim_time * 8.5) * 0.45
				wing_r_pivot.rotation = -sin(anim_time * 8.5) * 0.45
			BossAnim.COLLAPSE:
				wing_l_pivot.rotation = 0.75
				wing_r_pivot.rotation = -0.75
				claw_l_pivot.rotation = 0.95
				claw_r_pivot.rotation = -0.95

	# Update orbiting embers
	var time_ms = Time.get_ticks_msec()
	for i in range(orbiting_embers.size()):
		var emb = orbiting_embers[i]
		var orb_angle = (time_ms * 0.0015) + (i * TAU / 6.0)
		var orb_dist = 90.0 + sin(time_ms * 0.003 + i) * 15.0
		emb.position = Vector2.RIGHT.rotated(orb_angle) * orb_dist

	# Update sigil sprite
	if sigil_sprite:
		sigil_sprite.visible = is_casting
		if is_casting:
			sigil_sprite.rotation += delta * 1.8
			sigil_sprite.modulate.a = 0.8 + sin(time_ms * 0.01) * 0.15

	# Update beam sprite
	if beam_sprite:
		if beam_charging:
			beam_sprite.visible = true
			beam_sprite.rotation = beam_angle
			beam_sprite.scale = Vector2(1.2, 0.4)
			beam_sprite.modulate = Color(1.5, 0.4, 0.4, 0.6)
		elif beam_active:
			beam_sprite.visible = true
			beam_sprite.rotation = beam_angle
			beam_sprite.scale = Vector2(1.2, 1.1 + sin(time_ms * 0.04) * 0.2)
			beam_sprite.modulate = Color.WHITE
		else:
			beam_sprite.visible = false

	# Skill rotation
	if warmup_timer > 0.0:
		warmup_timer -= delta
	else:
		skill_timer += delta
		if skill_timer >= skill_cooldown and not is_casting:
			skill_timer = 0.0
			_select_and_cast_skill()

	_process_active_skills(delta)

func _select_and_cast_skill() -> void:
	var available_skills = ["shockwave", "dimensional_cleave", "chaos_spiral"]
	if current_phase >= 2:
		available_skills.append_array(["void_beam", "gravity_vortex", "abyssal_orbs"])
	if current_phase >= 3:
		available_skills.append_array(["meteor_storm", "apocalypse_barrage"])

	var primary_skill = available_skills[randi() % available_skills.size()]
	active_skill_name = primary_skill
	GameManager.boss_skill_announced.emit(primary_skill)
	_execute_skill(primary_skill)

	# High Phase Combo Multi-casting (Phase 2+: 35% chance, Phase 3+: 60% chance)
	var combo_chance = 0.35 if current_phase == 2 else (0.60 if current_phase >= 3 else 0.0)
	if randf() < combo_chance:
		var combo_pool = ["gravity_vortex", "shockwave", "abyssal_orbs", "dimensional_cleave"]
		var secondary_skill = combo_pool[randi() % combo_pool.size()]
		if secondary_skill != primary_skill:
			_execute_skill(secondary_skill)

func _execute_skill(skill_name: String) -> void:
	match skill_name:
		"chaos_spiral": cast_chaos_spiral()
		"void_beam": cast_void_beam()
		"meteor_storm": cast_meteor_storm()
		"gravity_vortex": cast_gravity_vortex()
		"shockwave": cast_shockwave()
		"dimensional_cleave": cast_dimensional_cleave()
		"abyssal_orbs": cast_abyssal_orbs()
		"apocalypse_barrage": cast_apocalypse_barrage()

# --- ANIMATION HELPER: AFTERIMAGE / PHANTOM TRAIL ---
func _spawn_afterimage(tint: Color = Color(0.8, 0.2, 1.0, 0.6), dur: float = 0.25) -> void:
	var ghost = Sprite2D.new()
	ghost.texture = base_boss_tex
	ghost.global_position = rig.global_position
	ghost.scale = rig.scale * scale
	ghost.rotation = rig.rotation + rotation
	ghost.modulate = tint
	get_parent().add_child(ghost)
	var t = create_tween()
	t.tween_property(ghost, "modulate:a", 0.0, dur)
	t.tween_callback(ghost.queue_free)

# --- SKILL 1: CHAOS SPIRAL (Bullet hell radial barrage) ---
func cast_chaos_spiral() -> void:
	is_casting = true
	anim_locked = true
	current_anim = BossAnim.ROAR

	# Windup squash
	var windup = create_tween()
	windup.tween_property(sprite, "scale", Vector2(1.25, 0.75), 0.15)
	windup.parallel().tween_property(sprite, "modulate", Color(1.8, 0.4, 2.0), 0.15)
	await windup.finished

	var count = 26 + (current_phase * 4)
	var speed = 320.0 + (current_phase * 25.0)
	var dmg = 45.0 + (current_phase * 10.0)

	for wave in range(2 + (1 if current_phase >= 3 else 0)):
		current_anim = BossAnim.SPRAY
		# Burst pop animation per wave
		_spawn_afterimage(Color(0.9, 0.2, 0.8, 0.65), 0.3)
		var burst = create_tween()
		burst.tween_property(sprite, "scale", Vector2(0.85, 1.3), 0.08)
		burst.tween_property(sprite, "scale", Vector2(1.05, 0.95), 0.1)

		var base_angle = randf_range(0, TAU)
		for i in range(count):
			var angle = base_angle + (float(i) / float(count)) * TAU
			var dir = Vector2.RIGHT.rotated(angle)
			_spawn_projectile(global_position + dir * 30.0, dir, speed, dmg, null, 0.0, Color(0.9, 0.2, 0.8))
		GameManager.play_tone(520.0, 0.08, 0.25)
		await get_tree().create_timer(0.32).timeout

	# Recover
	var recover = create_tween()
	recover.tween_property(sprite, "scale", Vector2.ONE, 0.12)
	recover.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.12)
	await recover.finished

	current_anim = BossAnim.IDLE
	anim_locked = false
	is_casting = false

# --- SKILL 2: VOID BEAM (Lethal sweeping death laser) ---
func cast_void_beam() -> void:
	if not player_ref: return
	is_casting = true
	anim_locked = true
	beam_charging = true
	current_anim = BossAnim.ROAR

	beam_angle = (player_ref.global_position - global_position).angle()
	beam_target_angle = beam_angle + (PI * 0.5 if randf() < 0.5 else -PI * 0.5)
	GameManager.play_sound("boss_laser_charge")

	# Telegraph charge: lean back in recoil opposite beam direction with intense tremor
	var charge_dir = Vector2.RIGHT.rotated(beam_angle)
	var charge_tween = create_tween()
	charge_tween.tween_property(sprite, "position", -charge_dir * 25.0, 0.2)
	charge_tween.parallel().tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.2)
	charge_tween.parallel().tween_property(sprite, "modulate", Color(2.8, 1.0, 3.2), 0.2)

	if laser_guide:
		laser_guide.visible = true
		laser_guide.rotation = beam_angle
		laser_guide.scale = Vector2(9.0, 1.2)
		laser_guide.modulate = Color(2.5, 0.4, 0.5, 0.85)

	# Charging tremor for 0.65s
	var charge_timer = 0.0
	while charge_timer < 0.65:
		var dt = get_physics_process_delta_time()
		charge_timer += dt
		anim_jitter = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		if laser_guide:
			laser_guide.rotation = beam_angle
			laser_guide.modulate.a = 0.5 + sin(charge_timer * 28.0) * 0.45
		await get_tree().process_frame
	anim_jitter = Vector2.ZERO

	if laser_guide:
		laser_guide.visible = false

	beam_charging = false
	beam_active = true
	current_anim = BossAnim.CHANNEL
	GameManager.play_sound("boss_laser_fire")
	GameManager.trigger_screen_shake(9.0, 1.8)
	GameManager.trigger_environment_tint(Color(0.85, 0.45, 0.95), 1.8)

	var elapsed = 0.0
	var duration = 1.8
	var ghost_timer = 0.0

	while elapsed < duration:
		var dt = get_physics_process_delta_time()
		elapsed += dt
		ghost_timer += dt
		beam_angle = lerp_angle(beam_angle, beam_target_angle, dt * 1.9)

		# Sprite aligns slightly with sweep
		sprite.rotation = (beam_angle + PI * 0.5) * 0.2
		anim_jitter = Vector2(randf_range(-2, 2), randf_range(-2, 2))

		if ghost_timer >= 0.15:
			ghost_timer = 0.0
			_spawn_afterimage(Color(0.8, 0.3, 1.0, 0.5), 0.25)

		# Raycast damage to player
		if player_ref and is_instance_valid(player_ref):
			var to_player = player_ref.global_position - global_position
			var diff = abs(wrapf(to_player.angle() - beam_angle, -PI, PI))
			if diff < 0.13 and to_player.length() < 950.0:
				if player_ref.has_method("take_hit"):
					player_ref.take_hit(150.0 * dt, to_player.normalized())

		await get_tree().process_frame

	anim_jitter = Vector2.ZERO
	beam_active = false

	# Smooth return
	var reset_tween = create_tween()
	reset_tween.tween_property(sprite, "position", Vector2.ZERO, 0.2)
	reset_tween.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.2)
	reset_tween.parallel().tween_property(sprite, "rotation", 0.0, 0.2)
	reset_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	await reset_tween.finished

	current_anim = BossAnim.IDLE
	anim_locked = false
	is_casting = false

# --- SKILL 3: METEOR STORM (Targeted ground AoE craters) ---
func cast_meteor_storm() -> void:
	if not player_ref: return
	is_casting = true
	anim_locked = true
	current_anim = BossAnim.CHANNEL

	# Ascend into the air with apocalyptic solar glow
	GameManager.trigger_environment_tint(Color(1.15, 0.65, 0.45), 1.8)
	var ascend = create_tween()
	ascend.tween_property(sprite, "position:y", -35.0, 0.25).set_trans(Tween.TRANS_SINE)
	ascend.parallel().tween_property(sprite, "scale", Vector2(0.85, 1.3), 0.25)
	ascend.parallel().tween_property(sprite, "modulate", Color(2.6, 1.2, 0.3), 0.25)
	await ascend.finished

	var count = 6 + current_phase * 2

	for i in range(count):
		if not player_ref: break
		var spread = Vector2(randf_range(-70, 70), randf_range(-70, 70))
		var target_pos = player_ref.global_position + spread
		active_telegraphs.append({
			"pos": target_pos,
			"radius": 80.0,
			"timer": 0.8,
			"max_time": 0.8,
			"damage": 170.0 + (current_phase * 30.0)
		})
		_spawn_crater_sprite(target_pos, 0.8)

		# Chest pump summon animation on each meteor
		_spawn_afterimage(Color(1.0, 0.5, 0.1, 0.5), 0.2)
		var pump = create_tween()
		pump.tween_property(sprite, "position:y", -25.0, 0.05)
		pump.tween_property(sprite, "position:y", -35.0, 0.08)

		GameManager.play_sound("boss_meteor")
		GameManager.trigger_screen_shake(5.0, 0.12)
		await get_tree().create_timer(0.2).timeout

	# Descend back to ground
	var land = create_tween()
	land.tween_property(sprite, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE)
	land.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.2)
	land.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	await land.finished

	current_anim = BossAnim.IDLE
	anim_locked = false
	is_casting = false

# --- SKILL 4: GRAVITY VORTEX (Black hole singularity) ---
func cast_gravity_vortex() -> void:
	anim_locked = true
	current_anim = BossAnim.CHANNEL
	GameManager.trigger_environment_tint(Color(0.45, 0.25, 0.65), 3.5)

	# Collapse inwards and spin into black hole singularity
	var collapse = create_tween()
	collapse.tween_property(sprite, "scale", Vector2(0.65, 0.65), 0.3)
	collapse.parallel().tween_property(sprite, "modulate", Color(0.2, 0.05, 0.4), 0.3)
	collapse.parallel().tween_property(sprite, "rotation_degrees", 360.0, 0.3)
	await collapse.finished

	# Explosive pop release
	_spawn_afterimage(Color(0.6, 0.1, 0.9, 0.7), 0.4)
	var pop = create_tween()
	pop.tween_property(sprite, "scale", Vector2(1.35, 1.35), 0.1).set_trans(Tween.TRANS_BOUNCE)
	pop.tween_property(sprite, "scale", Vector2.ONE, 0.2)
	pop.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	pop.parallel().tween_property(sprite, "rotation_degrees", 0.0, 0.2)

	vortex_timer = 4.0
	vortex_pos = Vector2(640, 360)
	_spawn_vortex_sprite(vortex_pos, 4.0)
	GameManager.play_sound("boss_vortex")
	GameManager.trigger_screen_shake(12.0, 0.35)

	await pop.finished
	current_anim = BossAnim.IDLE
	anim_locked = false

# --- SKILL 5: SHOCKWAVE SLAM (The Leap & Earthshaking Slam) ---
func cast_shockwave() -> void:
	anim_locked = true
	current_anim = BossAnim.SLAM

	# The Leap: Jump high into the air
	var jump = create_tween()
	jump.tween_property(sprite, "position:y", -52.0, 0.25).set_trans(Tween.TRANS_CUBIC)
	jump.parallel().tween_property(sprite, "scale", Vector2(0.7, 1.45), 0.25)
	jump.parallel().tween_property(sprite, "modulate", Color(1.8, 0.8, 2.2), 0.25)
	await jump.finished

	# Apex anticipation pause
	await get_tree().create_timer(0.12).timeout

	# The Slam: Drop down violently onto ground
	var slam = create_tween()
	slam.tween_property(sprite, "position:y", 12.0, 0.1).set_trans(Tween.TRANS_EXPO)
	slam.parallel().tween_property(sprite, "scale", Vector2(1.5, 0.55), 0.1)
	await slam.finished

	# Spawn shockwave right at impact!
	_spawn_afterimage(Color(0.8, 0.3, 1.0, 0.8), 0.35)
	active_shockwaves.append({
		"pos": global_position,
		"radius": 30.0,
		"max_radius": 800.0,
		"speed": 580.0,
		"damage": 95.0 + (current_phase * 20.0),
		"hit_players": []
	})
	_spawn_shockwave_sprite(global_position, 800.0, 1.2)
	GameManager.play_sound("boss_slam")
	GameManager.trigger_screen_shake(18.0, 0.45)

	# Elastic recovery bounce
	var rebound = create_tween()
	rebound.tween_property(sprite, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_ELASTIC)
	rebound.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.25)
	rebound.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	await rebound.finished

	current_anim = BossAnim.IDLE
	anim_locked = false

# --- SKILL 6: DIMENSIONAL CLEAVE (Phantom Slice Dash) ---
func cast_dimensional_cleave() -> void:
	if not player_ref: return
	anim_locked = true
	current_anim = BossAnim.FLY

	# Phantom cross-slice animation
	var slash_angle = (player_ref.global_position - global_position).angle()
	sprite.rotation = slash_angle
	_spawn_afterimage(Color(1.0, 0.2, 0.4, 0.7), 0.3)

	var slash_tween = create_tween()
	var forward = Vector2.RIGHT.rotated(slash_angle) * 45.0
	slash_tween.tween_property(sprite, "position", forward, 0.1)
	slash_tween.parallel().tween_property(sprite, "scale", Vector2(1.4, 0.7), 0.1)
	slash_tween.parallel().tween_property(sprite, "modulate", Color(3.0, 0.8, 1.2), 0.1)
	slash_tween.tween_property(sprite, "position", Vector2.ZERO, 0.15)
	slash_tween.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.15)
	slash_tween.parallel().tween_property(sprite, "rotation", 0.0, 0.15)
	slash_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.15)

	var cleave_count = 2 + (1 if current_phase >= 2 else 0)
	for i in range(cleave_count):
		var center = player_ref.global_position
		var angle = randf_range(0, PI)
		var dir = Vector2.RIGHT.rotated(angle)
		var p1 = center - dir * 700.0
		var p2 = center + dir * 700.0
		active_cleaves.append({
			"start": p1,
			"end": p2,
			"timer": 0.75,
			"max_time": 0.75,
			"damage": 120.0 + (current_phase * 25.0),
			"active_time": 0.35,
			"width": 26.0,
			"hit_players": []
		})
		_spawn_cleave_sprite(center, angle, 1400.0, 0.75)
	GameManager.play_tone(680.0, 0.25, 0.3)

	await slash_tween.finished
	current_anim = BossAnim.IDLE
	anim_locked = false

# --- SKILL 7: ABYSSAL ORBS (Heartbeat bloom pulse) ---
func cast_abyssal_orbs() -> void:
	if not player_ref: return
	anim_locked = true
	current_anim = BossAnim.ROAR

	# Inhale ethereal cyan
	var inhale = create_tween()
	inhale.tween_property(sprite, "scale", Vector2(0.85, 0.85), 0.2)
	inhale.parallel().tween_property(sprite, "modulate", Color(0.3, 2.2, 2.8), 0.2)
	await inhale.finished

	# Outward bloom pulse
	_spawn_afterimage(Color(0.2, 0.8, 1.0, 0.8), 0.35)
	var bloom = create_tween()
	bloom.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.12).set_trans(Tween.TRANS_BOUNCE)
	bloom.tween_property(sprite, "scale", Vector2.ONE, 0.2)
	bloom.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.2)

	var orb_count = 5 + current_phase * 2
	var dmg = 110.0 + (current_phase * 20.0)
	for i in range(orb_count):
		var angle = (float(i) / float(orb_count)) * TAU
		var dir = Vector2.RIGHT.rotated(angle)
		_spawn_projectile(
			global_position + dir * 40.0,
			dir,
			220.0,
			dmg,
			player_ref,
			2.8,
			Color(0.2, 0.8, 1.0)
		)
	GameManager.play_tone(380.0, 0.3, 0.3)

	await bloom.finished
	current_anim = BossAnim.IDLE
	anim_locked = false

# --- SKILL 8: APOCALYPSE BARRAGE (Gatling Recoil Volley) ---
func cast_apocalypse_barrage() -> void:
	if not player_ref: return
	is_casting = true
	anim_locked = true
	current_anim = BossAnim.SPRAY

	var shot_count = 16 + (current_phase * 4)
	var dmg = 65.0 + (current_phase * 12.0)
	sprite.modulate = Color(2.6, 0.9, 0.4)

	for i in range(shot_count):
		if not player_ref: break
		var to_player = (player_ref.global_position - global_position).normalized()
		var spread_angle = randf_range(-0.16, 0.16)
		var shoot_dir = to_player.rotated(spread_angle)

		# Machine gun kickback recoil
		sprite.position = -shoot_dir * 14.0
		sprite.scale = Vector2(1.15, 0.85)

		_spawn_projectile(global_position + shoot_dir * 35.0, shoot_dir, 560.0, dmg, null, 0.0, Color(1.0, 0.3, 0.1))
		GameManager.play_tone(480.0, 0.04, 0.2)

		await get_tree().create_timer(0.045).timeout
		# Reset position between shots
		sprite.position = Vector2.ZERO
		sprite.scale = Vector2.ONE
		await get_tree().create_timer(0.045).timeout

	sprite.modulate = Color.WHITE
	current_anim = BossAnim.IDLE
	anim_locked = false
	is_casting = false

func _process_active_skills(delta: float) -> void:
	# 1. Process ground meteor telegraphs
	var remaining_telegraphs: Array = []
	for t in active_telegraphs:
		t["timer"] -= delta
		if t["timer"] <= 0.0:
			# Explosion detonates
			GameManager.play_tone(220.0, 0.18, 0.35)
			if player_ref and is_instance_valid(player_ref):
				if player_ref.global_position.distance_to(t["pos"]) <= t["radius"]:
					if player_ref.has_method("take_hit"):
						player_ref.take_hit(t["damage"], (player_ref.global_position - t["pos"]).normalized())
		else:
			remaining_telegraphs.append(t)
	active_telegraphs = remaining_telegraphs

	# 2. Process shockwaves
	var remaining_waves: Array = []
	for w in active_shockwaves:
		w["radius"] += w["speed"] * delta
		if player_ref and is_instance_valid(player_ref) and not (player_ref in w["hit_players"]):
			var dist = player_ref.global_position.distance_to(w["pos"])
			if abs(dist - w["radius"]) < 32.0:
				w["hit_players"].append(player_ref)
				if player_ref.has_method("take_hit"):
					player_ref.take_hit(w["damage"], (player_ref.global_position - w["pos"]).normalized())
		if w["radius"] < w["max_radius"]:
			remaining_waves.append(w)
	active_shockwaves = remaining_waves

	# 3. Process gravity vortex
	if vortex_timer > 0.0:
		vortex_timer -= delta
		if player_ref and is_instance_valid(player_ref):
			var to_vortex = vortex_pos - player_ref.global_position
			var pull = to_vortex.normalized() * clamp(850.0 / max(to_vortex.length(), 20.0), 140.0, 420.0)
			player_ref.global_position += pull * delta
			if to_vortex.length() < 70.0 and player_ref.has_method("take_hit"):
				player_ref.take_hit(140.0 * delta, to_vortex.normalized())

	# 4. Process dimensional cleaves
	var remaining_cleaves: Array = []
	for c in active_cleaves:
		if c["timer"] > 0.0:
			c["timer"] -= delta
			remaining_cleaves.append(c)
		else:
			c["active_time"] -= delta
			# Damage check while rift is exploding
			if player_ref and is_instance_valid(player_ref) and not (player_ref in c["hit_players"]):
				var d = _distance_point_to_segment(player_ref.global_position, c["start"], c["end"])
				if d <= c["width"]:
					c["hit_players"].append(player_ref)
					if player_ref.has_method("take_hit"):
						var norm = (player_ref.global_position - c["start"]).orthogonal().normalized()
						player_ref.take_hit(c["damage"], norm)
			if c["active_time"] > 0.0:
				remaining_cleaves.append(c)
	active_cleaves = remaining_cleaves

func _distance_point_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ab_len_sq = ab.length_squared()
	if ab_len_sq == 0.0: return p.distance_to(a)
	var t = clamp((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var projection = a + t * ab
	return p.distance_to(projection)

func _spawn_projectile(pos: Vector2, dir: Vector2, spd: float, dmg: float, target: Node2D = null, turn_spd: float = 0.0, tint: Color = Color.WHITE) -> void:
	var proj = PROJECTILE_SCENE.instantiate()
	proj.global_position = pos
	proj.setup(dir, spd, dmg, target, turn_spd, tint)
	get_parent().add_child(proj)

func _spawn_shockwave_sprite(pos: Vector2, max_rad: float, dur: float) -> void:
	var sw = Sprite2D.new()
	sw.texture = TEX_ENERGY_RING
	sw.global_position = pos
	sw.scale = Vector2(0.1, 0.1)
	sw.modulate = Color(1.8, 1.2, 2.8, 0.95)
	get_parent().add_child(sw)
	var t = create_tween()
	var target_scale = max_rad / 64.0
	t.tween_property(sw, "scale", Vector2(target_scale, target_scale), dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(sw, "modulate:a", 0.0, dur)
	t.tween_callback(sw.queue_free)

func _spawn_crater_sprite(pos: Vector2, dur: float) -> void:
	var cr = Sprite2D.new()
	cr.texture = TEX_CRATER
	cr.global_position = pos
	cr.scale = Vector2(0.8, 0.8)
	get_parent().add_child(cr)
	var t = create_tween()
	t.tween_property(cr, "scale", Vector2(1.1, 1.1), dur)
	t.tween_callback(func():
		var met = Sprite2D.new()
		met.texture = TEX_METEOR
		met.global_position = pos - Vector2(0, 350)
		get_parent().add_child(met)
		var mt = create_tween()
		mt.tween_property(met, "global_position:y", pos.y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		mt.tween_callback(func():
			_spawn_shockwave_sprite(pos, 160.0, 0.35)
			met.queue_free()
			var cfade = create_tween()
			cfade.tween_property(cr, "modulate:a", 0.0, 0.4)
			cfade.tween_callback(cr.queue_free)
		)
	)

func _spawn_cleave_sprite(center: Vector2, angle: float, length: float, dur: float) -> void:
	var cl = Sprite2D.new()
	cl.texture = TEX_CLEAVE
	cl.global_position = center
	cl.rotation = angle
	cl.scale = Vector2(length / 800.0, 0.2)
	get_parent().add_child(cl)
	var t = create_tween()
	t.tween_property(cl, "scale:y", 1.2, 0.12)
	t.tween_property(cl, "modulate:a", 0.0, dur)
	t.tween_callback(cl.queue_free)

func _spawn_vortex_sprite(pos: Vector2, dur: float) -> void:
	var vx = Sprite2D.new()
	vx.texture = TEX_VORTEX
	vx.global_position = pos
	vx.scale = Vector2(0.3, 0.3)
	get_parent().add_child(vx)
	var t = create_tween()
	t.tween_property(vx, "scale", Vector2(1.2, 1.2), 0.3)
	t.parallel().tween_property(vx, "rotation", TAU * 4.0, dur)
	t.tween_property(vx, "scale", Vector2(0.1, 0.1), 0.25).set_delay(dur - 0.55)
	t.tween_callback(vx.queue_free)

func _spawn_hit_spark_fx(pos: Vector2) -> void:
	for i in range(4):
		var sp = Sprite2D.new()
		sp.texture = TEX_SPARK
		sp.global_position = pos + Vector2(randf_range(-25, 25), randf_range(-25, 25))
		sp.scale = Vector2(randf_range(0.5, 0.9), randf_range(0.5, 0.9))
		get_parent().add_child(sp)
		var t = create_tween()
		t.tween_property(sp, "scale", Vector2(1.2, 1.2), 0.16)
		t.parallel().tween_property(sp, "modulate:a", 0.0, 0.16)
		t.tween_callback(sp.queue_free)
