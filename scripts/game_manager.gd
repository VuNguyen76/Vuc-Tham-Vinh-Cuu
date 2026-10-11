extends Node

# GameManager.gd - Eternal Void Colossus (QVVC)
# Global combat manager, real-time DPS tracking, procedural audio synthesizer, screen FX

signal boss_hit(damage: float, is_crit: bool, attacker_name: String, hit_pos: Vector2)
signal boss_phase_broken(phase_num: int)
signal boss_skill_announced(skill_id: String)
signal item_dropped(item_id: String, amount: int, drop_pos: Vector2)
signal item_collected(item_id: String, amount: int)
signal inventory_updated()
signal dps_updated(leaderboard: Array)
signal screen_shake_requested(intensity: float, duration: float)
signal environment_tint_requested(tint_color: Color, duration: float)

var total_boss_damage: float = 0.0
var boss_current_phase: int = 1
var dps_records: Dictionary = {}
var dps_timer: float = 0.0

# Procedural audio generator
var audio_player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0

func _ready() -> void:
	_setup_audio_synth()

func _setup_audio_synth() -> void:
	audio_player = AudioStreamPlayer.new()
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.15
	audio_player.stream = generator
	audio_player.volume_db = -4.0
	add_child(audio_player)
	audio_player.play()
	playback = audio_player.get_stream_playback()

# Play a short synthetic tone (frequency Hz)
func play_tone(freq: float, duration: float, volume: float = 0.3) -> void:
	if not playback: return
	var frames = int(sample_rate * duration)
	var phase = 0.0
	var phase_step = (freq * TAU) / sample_rate
	for i in range(frames):
		if playback.get_frames_available() <= 0: break
		var env = 1.0 - (float(i) / float(frames))
		var sample = sin(phase) * env * volume
		playback.push_frame(Vector2(sample, sample))
		phase += phase_step
		if phase >= TAU: phase -= TAU

# Rich procedural audio presets for skills, impacts, and combat
func play_sound(sfx_name: String) -> void:
	if not playback: return
	match sfx_name:
		"sword_slash":
			_play_freq_slide(650.0, 220.0, 0.08, 0.35)
		"skill_whirlwind":
			_play_freq_slide(300.0, 750.0, 0.18, 0.4)
			_play_freq_slide(750.0, 200.0, 0.12, 0.35)
		"skill_thrust":
			_play_freq_slide(1100.0, 350.0, 0.14, 0.45)
		"skill_ultimate":
			_play_freq_slide(180.0, 60.0, 0.4, 0.6)
			play_tone(70.0, 0.5, 0.55)
		"dash":
			_play_freq_slide(700.0, 1200.0, 0.09, 0.28)
		"boss_slam":
			_play_freq_slide(140.0, 45.0, 0.35, 0.6)
		"boss_laser_charge":
			_play_freq_slide(220.0, 880.0, 0.65, 0.4)
		"boss_laser_fire":
			_play_freq_slide(950.0, 850.0, 1.6, 0.45)
		"boss_meteor":
			_play_freq_slide(500.0, 160.0, 0.2, 0.4)
		"boss_vortex":
			_play_freq_slide(120.0, 200.0, 0.4, 0.45)
		"crit_hit":
			play_tone(1200.0, 0.06, 0.35)
			play_tone(800.0, 0.08, 0.3)
		"phase_break":
			_play_freq_slide(250.0, 900.0, 0.45, 0.55)
		"equip":
			play_tone(1350.0, 0.07, 0.3)
		"craft":
			_play_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.08, 0.35)
		"skill_aegis":
			_play_arpeggio([440.0, 659.25, 880.0, 1318.5], 0.07, 0.45)
		"skill_lightning":
			_play_freq_slide(1800.0, 85.0, 0.28, 0.65)
			play_tone(55.0, 0.35, 0.6)
		"monster_hit":
			_play_freq_slide(340.0, 110.0, 0.06, 0.3)
		"monster_die":
			_play_freq_slide(220.0, 60.0, 0.18, 0.35)
		"chest_open":
			_play_arpeggio([587.33, 739.99, 880.0, 1174.66, 1479.98], 0.06, 0.45)
		_:
			play_tone(440.0, 0.1, 0.3)

func _play_freq_slide(start_f: float, end_f: float, dur: float, vol: float) -> void:
	if not playback: return
	var frames = int(sample_rate * dur)
	var phase = 0.0
	for i in range(frames):
		if playback.get_frames_available() <= 0: break
		var t = float(i) / float(frames)
		var cur_freq = lerp(start_f, end_f, t)
		var phase_step = (cur_freq * TAU) / sample_rate
		var env = sin(t * PI) * vol
		var sample = sin(phase) * env
		playback.push_frame(Vector2(sample, sample))
		phase += phase_step
		if phase >= TAU: phase -= TAU

func _play_arpeggio(freqs: Array, note_dur: float, vol: float) -> void:
	for f in freqs:
		play_tone(f, note_dur, vol)

func trigger_screen_shake(intensity: float = 10.0, duration: float = 0.3) -> void:
	screen_shake_requested.emit(intensity, duration)

func trigger_environment_tint(tint_color: Color, duration: float = 0.5) -> void:
	environment_tint_requested.emit(tint_color, duration)

func record_damage(attacker_name: String, dmg: float) -> void:
	total_boss_damage += dmg
	if not dps_records.has(attacker_name):
		dps_records[attacker_name] = { "damage": 0.0, "recent_damage": 0.0 }
	dps_records[attacker_name]["damage"] += dmg
	dps_records[attacker_name]["recent_damage"] += dmg

func _process(delta: float) -> void:
	dps_timer += delta
	if dps_timer >= 1.0:
		dps_timer = 0.0
		_update_dps_leaderboard()

func _update_dps_leaderboard() -> void:
	var list: Array = []
	for name in dps_records.keys():
		var rec = dps_records[name]
		var dps = rec["recent_damage"]
		rec["recent_damage"] = 0.0
		list.append({
			"name": name,
			"dps": dps,
			"total": rec["damage"]
		})
	list.sort_custom(func(a, b): return a["total"] > b["total"])
	dps_updated.emit(list)
