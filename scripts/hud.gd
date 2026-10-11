extends CanvasLayer

signal game_started()

# Localized HUD controller with styled Inventory (Balo), Forge (Lo Ren), and Player Skill Bar

@onready var title_screen: Control = $TitleScreen
@onready var btn_start_game: Button = $TitleScreen/BtnStartGame

@onready var boss_hp_bar: TextureProgressBar = $BossPanel/BossHpBar
@onready var boss_hp_label: Label = $BossPanel/BossHpBar/BossHpLabel
@onready var boss_info: Label = $BossPanel/BossInfo
@onready var warning_banner: NinePatchRect = $WarningBanner
@onready var skill_warning: Label = $WarningBanner/SkillWarning
@onready var player_hp_bar: TextureProgressBar = $PlayerPanel/PlayerHpBar
@onready var player_hp_label: Label = $PlayerPanel/PlayerHpBar/PlayerHpLabel
@onready var player_mp_bar: TextureProgressBar = $PlayerPanel/PlayerMpBar
@onready var player_mp_label: Label = $PlayerPanel/PlayerMpBar/PlayerMpLabel
@onready var stats_info: Label = $PlayerPanel/StatsInfo
@onready var dps_info: Label = $DpsPanel/DpsInfo
@onready var server_status_label: Label = $ServerStatusPill/ServerStatusLabel
@onready var btn_bag: Button = $BtnBag

# Player Skill Bar
@onready var skill_bar: HBoxContainer = $SkillBar
@onready var skill_q: Control = $SkillBar/SkillQ
@onready var label_q: Label = $SkillBar/SkillQ/Margin/HBox/VBox/LabelQ
@onready var status_q: Label = $SkillBar/SkillQ/Margin/HBox/VBox/StatusQ
@onready var skill_e: Control = $SkillBar/SkillE
@onready var label_e: Label = $SkillBar/SkillE/Margin/HBox/VBox/LabelE
@onready var status_e: Label = $SkillBar/SkillE/Margin/HBox/VBox/StatusE
@onready var skill_r: Control = $SkillBar/SkillR
@onready var label_r: Label = $SkillBar/SkillR/Margin/HBox/VBox/LabelR
@onready var status_r: Label = $SkillBar/SkillR/Margin/HBox/VBox/StatusR
@onready var skill_dash: Control = $SkillBar/SkillDash
@onready var label_dash: Label = $SkillBar/SkillDash/Margin/HBox/VBox/LabelDash
@onready var status_dash: Label = $SkillBar/SkillDash/Margin/HBox/VBox/StatusDash
@onready var skill_f: Control = $SkillBar/SkillF
@onready var label_f: Label = $SkillBar/SkillF/Margin/HBox/VBox/LabelF
@onready var status_f: Label = $SkillBar/SkillF/Margin/HBox/VBox/StatusF
@onready var skill_space: Control = $SkillBar/SkillSpace
@onready var label_space: Label = $SkillBar/SkillSpace/Margin/HBox/VBox/LabelSpace
@onready var status_space: Label = $SkillBar/SkillSpace/Margin/HBox/VBox/StatusSpace

# Modal components
@onready var modal_root: Control = $ModalRoot
@onready var modal_panel: Control = $ModalRoot/ModalPanel
@onready var btn_tab_bag: Button = $ModalRoot/ModalPanel/Margin/VBox/HeaderHBox/BtnTabBag
@onready var btn_tab_forge: Button = $ModalRoot/ModalPanel/Margin/VBox/HeaderHBox/BtnTabForge
@onready var btn_tab_leaderboard: Button = $ModalRoot/ModalPanel/Margin/VBox/HeaderHBox/BtnTabLeaderboard
@onready var btn_close: Button = $ModalRoot/ModalPanel/Margin/VBox/HeaderHBox/BtnClose
@onready var tab_bag: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabBag
@onready var bag_capacity_label: Label = $ModalRoot/ModalPanel/Margin/VBox/TabBag/BagHeader/BagCapacityLabel
@onready var tab_forge: HBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabForge
@onready var tab_leaderboard: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabLeaderboard
@onready var btn_sync_cloud: Button = $ModalRoot/ModalPanel/Margin/VBox/TabLeaderboard/LbHeader/BtnSyncCloud
@onready var leaderboard_list: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabLeaderboard/LeaderboardScroll/LeaderboardList
@onready var item_list: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabBag/BagScroll/ItemList

# Forge components
@onready var enhance_title: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/EnhanceTitle
@onready var weapon_card: PanelContainer = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/WeaponCard
@onready var wpn_icon: TextureRect = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/WeaponCard/CardMargin/HBox/WpnIcon
@onready var wpn_name: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/WeaponCard/CardMargin/HBox/VBox/WpnName
@onready var wpn_stats: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/WeaponCard/CardMargin/HBox/VBox/WpnStats
@onready var next_stats: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/NextStats
@onready var cost_label: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/CostLabel
@onready var cost_container: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/CostContainer
@onready var btn_upgrade: Button = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol/BtnUpgrade
@onready var craft_title: Label = $ModalRoot/ModalPanel/Margin/VBox/TabForge/CraftCol/CraftTitle
@onready var craft_list: VBoxContainer = $ModalRoot/ModalPanel/Margin/VBox/TabForge/CraftCol/CraftScroll/CraftList

var player_ref: Node2D = null
var warning_tween: Tween = null
var current_tab: String = "bag"
var forge_slot: String = "weapon"
var btn_sel_wpn: Button = null
var btn_sel_arm: Button = null

func _ready() -> void:
	modal_root.visible = false
	warning_banner.visible = false
	warning_banner.modulate.a = 0.0

	if title_screen:
		if "--test-skills" in OS.get_cmdline_args() or "--test-skills" in OS.get_cmdline_user_args():
			title_screen.visible = false
		else:
			title_screen.visible = true
			title_screen.modulate.a = 1.0
			if btn_start_game:
				btn_start_game.pressed.connect(func():
					var tw = create_tween()
					tw.tween_property(title_screen, "modulate:a", 0.0, 0.3)
					tw.tween_callback(func():
						title_screen.visible = false
						game_started.emit()
					)
					GameManager.play_sound("crit_hit")
				)

	btn_bag.text = " %s [B]" % Localization.tr_text("btn_bag")
	btn_tab_bag.text = Localization.tr_text("tab_bag")
	btn_tab_forge.text = Localization.tr_text("tab_forge")
	btn_tab_leaderboard.text = Localization.tr_text("tab_leaderboard")
	btn_sync_cloud.text = "Đồng Bộ Đám Mây"
	btn_close.text = Localization.tr_text("btn_close")
	enhance_title.text = Localization.tr_text("lbl_forge_upgrade")
	craft_title.text = Localization.tr_text("lbl_forge_craft")
	cost_label.text = Localization.tr_text("lbl_cost")

	_apply_card_style(weapon_card)

	btn_bag.pressed.connect(func():
		modal_root.visible = not modal_root.visible
		if modal_root.visible: _refresh_ui()
	)

	btn_close.pressed.connect(func():
		modal_root.visible = false
	)

	btn_tab_bag.pressed.connect(func():
		current_tab = "bag"
		_switch_tab()
	)

	btn_tab_forge.pressed.connect(func():
		current_tab = "forge"
		_switch_tab()
	)

	btn_tab_leaderboard.pressed.connect(func():
		current_tab = "leaderboard"
		_switch_tab()
	)

	btn_sync_cloud.pressed.connect(func():
		if not player_ref: return
		var max_dps = 0.0
		var rec = GameManager.dps_records.get(player_ref.player_id, {})
		max_dps = rec.get("damage", 0.0)
		NetworkManager.sync_player_save(player_ref, GameManager.boss_current_phase, max_dps, GameManager.total_boss_damage)
		btn_sync_cloud.text = "Đang Đồng Bộ..."
		await get_tree().create_timer(0.6).timeout
		btn_sync_cloud.text = "Đã Đồng Bộ!"
		await get_tree().create_timer(1.2).timeout
		btn_sync_cloud.text = "Đồng Bộ Đám Mây"
		_refresh_leaderboard()
	)

	btn_upgrade.pressed.connect(func():
		if not player_ref: return
		var success = false
		if forge_slot == "weapon":
			success = player_ref.upgrade_weapon()
		else:
			success = player_ref.upgrade_armor()
		if success:
			_refresh_ui()
	)

	GameManager.dps_updated.connect(_on_dps_updated)
	GameManager.boss_skill_announced.connect(_on_boss_skill_announced)
	GameManager.boss_phase_broken.connect(_on_boss_phase_broken)
	NetworkManager.server_status_changed.connect(_on_server_status_changed)
	NetworkManager.leaderboard_updated.connect(_on_network_leaderboard_updated)
	_on_server_status_changed(NetworkManager.is_online)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_B:
			modal_root.visible = not modal_root.visible
			if modal_root.visible:
				_refresh_ui()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and modal_root.visible:
			modal_root.visible = false
			get_viewport().set_input_as_handled()

func is_ui_blocking() -> bool:
	return (title_screen != null and title_screen.visible) or (modal_root != null and modal_root.visible)

func bind_player(p: Node2D) -> void:
	player_ref = p
	if "hud_ref" in player_ref:
		player_ref.hud_ref = self
	player_ref.stats_updated.connect(_refresh_ui)
	player_ref.inventory_changed.connect(_refresh_ui)
	player_ref.health_changed.connect(_on_player_health_changed)
	player_ref.mana_changed.connect(_on_player_mana_changed)
	player_ref.skills_updated.connect(_on_player_skills_updated)
	_on_player_health_changed(player_ref.current_health, player_ref.max_health)
	_on_player_mana_changed(player_ref.current_mana, player_ref.max_mana)
	_refresh_ui()

func update_boss(hp: float, max_hp: float, phase: int) -> void:
	boss_hp_bar.max_value = max_hp
	boss_hp_bar.value = hp
	var floor_title_key = "floor_%d_title" % clampi(phase, 1, 4)
	var floor_title = Localization.tr_text(floor_title_key)
	boss_info.text = floor_title
	if boss_hp_label:
		var pct = int((hp / max(max_hp, 1.0)) * 100.0)
		boss_hp_label.text = "%s / %s (%d%%)" % [_format_number(hp), _format_number(max_hp), pct]

func _format_number(val: float) -> String:
	var n = int(val)
	var s = str(n)
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	return res

func _on_player_skills_updated(q_rat: float, e_rat: float, r_rat: float, dash_rat: float, f_rat: float = 0.0, space_rat: float = 0.0) -> void:
	var cur_mp = player_ref.current_mana if player_ref else 100.0
	_update_skill_slot(skill_q, status_q, q_rat, 25, cur_mp, Color(0.3, 0.9, 1.0))
	_update_skill_slot(skill_e, status_e, e_rat, 30, cur_mp, Color(0.85, 0.5, 1.0))
	_update_skill_slot(skill_r, status_r, r_rat, 60, cur_mp, Color(1.0, 0.85, 0.3))
	_update_skill_slot(skill_f, status_f, f_rat, 35, cur_mp, Color(1.0, 0.85, 0.3))
	_update_skill_slot(skill_space, status_space, space_rat, 50, cur_mp, Color(0.4, 0.9, 1.0))
	_update_skill_slot(skill_dash, status_dash, dash_rat, 15, cur_mp, Color(0.4, 1.0, 0.7))

func _update_skill_slot(panel: Control, status_lbl: Label, ratio: float, cost: int, cur_mp: float, ready_color: Color) -> void:
	if ratio > 0.0:
		status_lbl.text = "%d MP • %.1fs" % [cost, ratio * 10.0]
		status_lbl.modulate = Color(0.9, 0.45, 0.45, 0.9)
		panel.modulate = Color(0.65, 0.65, 0.7)
	elif cur_mp < cost:
		status_lbl.text = "%d MP • Thiếu MP" % cost
		status_lbl.modulate = Color(0.85, 0.6, 0.3, 0.85)
		panel.modulate = Color(0.8, 0.8, 0.85)
	else:
		status_lbl.text = "%d MP • Sẵn Sàng" % cost
		status_lbl.modulate = ready_color
		panel.modulate = Color.WHITE

func _switch_tab() -> void:
	tab_bag.visible = (current_tab == "bag")
	tab_forge.visible = (current_tab == "forge")
	tab_leaderboard.visible = (current_tab == "leaderboard")

	btn_tab_bag.modulate = Color(1.2, 1.2, 1.0) if current_tab == "bag" else Color.WHITE
	btn_tab_forge.modulate = Color(1.2, 1.2, 1.0) if current_tab == "forge" else Color.WHITE
	btn_tab_leaderboard.modulate = Color(1.2, 1.2, 1.0) if current_tab == "leaderboard" else Color.WHITE

	if current_tab == "bag":
		_refresh_bag()
	elif current_tab == "forge":
		_refresh_forge()
	else:
		_refresh_leaderboard()

func _refresh_ui() -> void:
	_refresh_stats()
	if modal_root.visible:
		if current_tab == "bag":
			_refresh_bag()
		elif current_tab == "forge":
			_refresh_forge()
		else:
			_refresh_leaderboard()

func _refresh_stats() -> void:
	if not player_ref: return
	var wpn_title = Localization.tr_text(player_ref.equipped_weapon)
	var wpn_lvl = (" +" + str(player_ref.weapon_upgrade)) if player_ref.weapon_upgrade > 0 else ""
	var arm_title = Localization.tr_text(player_ref.equipped_armor) if player_ref.equipped_armor != "" else "Không có"
	var arm_lvl = (" +" + str(player_ref.armor_upgrade)) if player_ref.armor_upgrade > 0 else ""
	var ring_title = Localization.tr_text(player_ref.equipped_ring) if player_ref.equipped_ring != "" else "Không có"
	var def_pct = int(player_ref.get_total_defense() * 100.0)

	var stones = player_ref.inventory.get("mat_stone", 0)
	var dust = player_ref.inventory.get("mat_dust", 0)
	var gems = player_ref.inventory.get("mat_gem", 0)
	var shards = player_ref.inventory.get("mat_shard", 0)

	stats_info.text = "⚔ %s%s   🛡 %s%s (-%d%%)   💍 %s\n💎 Đá: %d   ✨ Bụi: %d   🔮 Ngọc: %d   ⭐ Mảnh: %d" % [
		wpn_title, wpn_lvl,
		arm_title, arm_lvl, def_pct,
		ring_title,
		stones, dust, gems, shards
	]

func _refresh_bag() -> void:
	if not player_ref: return
	if bag_capacity_label:
		bag_capacity_label.text = Localization.tr_text("lbl_capacity") % [player_ref.inventory.keys().size(), player_ref.MAX_BAG_SLOTS]

	for c in item_list.get_children(): c.queue_free()

	var inv = player_ref.inventory
	for id in inv.keys():
		var count = inv[id]
		if count <= 0: continue

		var item_data = ItemsDatabase.ITEMS.get(id, {})
		var tier = item_data.get("tier", 0)
		var tier_col = ItemsDatabase.get_tier_color(tier)

		var card = PanelContainer.new()
		_apply_card_style(card)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		margin.add_child(hbox)

		# Icon
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(40, 40)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var icon_tex = ItemsDatabase.get_item_icon(id)
		if icon_tex: icon_rect.texture = icon_tex
		hbox.add_child(icon_rect)

		# Info VBox
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl = Label.new()
		name_lbl.text = "%s x%d" % [Localization.tr_text(id), count]
		name_lbl.modulate = tier_col
		info_vbox.add_child(name_lbl)

		var desc_lbl = Label.new()
		var item_type = item_data.get("type", -1)
		if item_type == ItemsDatabase.ItemType.WEAPON:
			desc_lbl.text = "%s: %d-%d | %s: %.1f/s" % [
				Localization.tr_text("lbl_atk"),
				item_data.get("min_atk", 0),
				item_data.get("max_atk", 0),
				Localization.tr_text("lbl_spd"),
				item_data.get("spd", 1.0)
			]
		elif item_type == ItemsDatabase.ItemType.ARMOR:
			var hp_b = int(item_data.get("hp_bonus", 0.0))
			var def_b = int(item_data.get("def", 0.0) * 100.0)
			desc_lbl.text = "Máu tối đa: +%d | Giảm sát thương: -%d%%" % [hp_b, def_b]
		elif item_type == ItemsDatabase.ItemType.ACCESSORY:
			var mp_b = int(item_data.get("mp_bonus", 0.0))
			var mp_r = item_data.get("mp_regen", 0.0)
			var crit_b = int(item_data.get("crit", 0.0) * 100.0)
			desc_lbl.text = "Năng lượng: +%d | Hồi MP: +%.1f/s | Chí mạng: +%d%%" % [mp_b, mp_r, crit_b]
		elif item_type == ItemsDatabase.ItemType.CHEST:
			desc_lbl.text = Localization.tr_text("desc_chest")
		else:
			desc_lbl.text = Localization.tr_text("desc_mat")
		desc_lbl.modulate = Color(0.8, 0.8, 0.85, 0.8)
		info_vbox.add_child(desc_lbl)
		hbox.add_child(info_vbox)

		# Action Button
		if item_type == ItemsDatabase.ItemType.WEAPON:
			if id == player_ref.equipped_weapon:
				var badge = Label.new()
				badge.text = Localization.tr_text("btn_equipped")
				badge.modulate = Color(0.4, 1.0, 0.4)
				hbox.add_child(badge)
			else:
				var equip_btn = Button.new()
				equip_btn.text = Localization.tr_text("btn_equip")
				equip_btn.custom_minimum_size = Vector2(90, 32)
				equip_btn.pressed.connect(func():
					player_ref.equip_weapon(id)
					_refresh_ui()
				)
				hbox.add_child(equip_btn)
		elif item_type == ItemsDatabase.ItemType.ARMOR:
			if id == player_ref.equipped_armor:
				var badge = Label.new()
				badge.text = Localization.tr_text("btn_equipped")
				badge.modulate = Color(0.4, 1.0, 0.4)
				hbox.add_child(badge)
			else:
				var equip_btn = Button.new()
				equip_btn.text = Localization.tr_text("btn_equip")
				equip_btn.custom_minimum_size = Vector2(90, 32)
				equip_btn.pressed.connect(func():
					player_ref.equip_armor(id)
					_refresh_ui()
				)
				hbox.add_child(equip_btn)
		elif item_type == ItemsDatabase.ItemType.ACCESSORY:
			if id == player_ref.equipped_ring:
				var badge = Label.new()
				badge.text = Localization.tr_text("btn_equipped")
				badge.modulate = Color(0.4, 1.0, 0.4)
				hbox.add_child(badge)
			else:
				var equip_btn = Button.new()
				equip_btn.text = Localization.tr_text("btn_equip")
				equip_btn.custom_minimum_size = Vector2(90, 32)
				equip_btn.pressed.connect(func():
					player_ref.equip_ring(id)
					_refresh_ui()
				)
				hbox.add_child(equip_btn)
		elif item_type == ItemsDatabase.ItemType.CHEST:
			var open_btn = Button.new()
			open_btn.text = Localization.tr_text("btn_open")
			open_btn.custom_minimum_size = Vector2(90, 32)
			open_btn.pressed.connect(func():
				player_ref.open_chest(id)
				_refresh_ui()
			)
			hbox.add_child(open_btn)

		item_list.add_child(card)

func _refresh_forge() -> void:
	if not player_ref: return

	# 1. Setup Slot Selector toggle buttons if not created
	var enhance_col = $ModalRoot/ModalPanel/Margin/VBox/TabForge/EnhanceCol
	if not btn_sel_wpn or not is_instance_valid(btn_sel_wpn):
		var sel_row = HBoxContainer.new()
		sel_row.name = "SlotSelector"
		sel_row.add_theme_constant_override("separation", 10)

		btn_sel_wpn = Button.new()
		btn_sel_wpn.text = "Vũ Khí [Đoản Kiếm]"
		btn_sel_wpn.custom_minimum_size = Vector2(140, 32)
		btn_sel_wpn.pressed.connect(func():
			forge_slot = "weapon"
			_refresh_forge()
		)
		sel_row.add_child(btn_sel_wpn)

		btn_sel_arm = Button.new()
		btn_sel_arm.text = "Giáp Trụ [Áo Giáp]"
		btn_sel_arm.custom_minimum_size = Vector2(140, 32)
		btn_sel_arm.pressed.connect(func():
			forge_slot = "armor"
			_refresh_forge()
		)
		sel_row.add_child(btn_sel_arm)

		enhance_col.add_child(sel_row)
		enhance_col.move_child(sel_row, 1)

	if forge_slot == "weapon":
		btn_sel_wpn.modulate = Color(1.2, 1.2, 1.0)
		btn_sel_arm.modulate = Color(0.7, 0.7, 0.7)
		enhance_title.text = "CƯỜNG HÓA VŨ KHÍ (Tối đa +10)"
		_render_weapon_enhancement()
	else:
		btn_sel_wpn.modulate = Color(0.7, 0.7, 0.7)
		btn_sel_arm.modulate = Color(1.2, 1.2, 1.0)
		enhance_title.text = "CƯỜNG HÓA GIÁP TRỤ (Tối đa +10)"
		_render_armor_enhancement()

	# 2. Crafting section
	_render_crafting_list()

func _render_weapon_enhancement() -> void:
	var wpn_id = player_ref.equipped_weapon
	var wpn_data = ItemsDatabase.ITEMS.get(wpn_id, {})
	var tier = wpn_data.get("tier", 0)
	var lvl = player_ref.weapon_upgrade

	var icon_tex = ItemsDatabase.get_item_icon(wpn_id)
	if icon_tex: wpn_icon.texture = icon_tex
	wpn_name.text = "%s +%d" % [Localization.tr_text(wpn_id), lvl]
	wpn_name.modulate = ItemsDatabase.get_tier_color(tier)

	var mult = 1.0 + (lvl * 0.15)
	var cur_min = int(wpn_data.get("min_atk", 25) * mult)
	var cur_max = int(wpn_data.get("max_atk", 40) * mult)
	wpn_stats.text = "%s: %d - %d | %s: %.1f/s" % [
		Localization.tr_text("lbl_atk"),
		cur_min,
		cur_max,
		Localization.tr_text("lbl_spd"),
		wpn_data.get("spd", 1.0)
	]

	for c in cost_container.get_children(): c.queue_free()

	if lvl >= player_ref.MAX_UPGRADE_LEVEL:
		next_stats.text = "Đã đạt cấp tối đa (+10)"
		next_stats.modulate = Color(1.0, 0.8, 0.2)
		btn_upgrade.text = "CẤP TỐI ĐA (+10)"
		btn_upgrade.disabled = true
		return

	var next_min = int(wpn_data.get("min_atk", 25) * (mult + 0.15))
	var next_max = int(wpn_data.get("max_atk", 40) * (mult + 0.15))
	next_stats.text = "Cấp tiếp theo (+%d): %d - %d (+15%% Sát thương)" % [lvl + 1, next_min, next_max]
	next_stats.modulate = Color(0.3, 0.9, 0.5)

	var need_stone = lvl + 1
	var need_dust = (lvl + 1) * 8
	var need_gem = max(0, lvl - 2)

	var has_stone = player_ref.inventory.get("mat_stone", 0)
	var has_dust = player_ref.inventory.get("mat_dust", 0)
	var has_gem = player_ref.inventory.get("mat_gem", 0)

	_add_cost_entry("mat_stone", has_stone, need_stone)
	_add_cost_entry("mat_dust", has_dust, need_dust)
	if need_gem > 0:
		_add_cost_entry("mat_gem", has_gem, need_gem)

	var can_upgrade = has_stone >= need_stone and has_dust >= need_dust and has_gem >= need_gem
	btn_upgrade.text = Localization.tr_text("btn_upgrade") % (lvl + 1)
	btn_upgrade.disabled = not can_upgrade

func _render_armor_enhancement() -> void:
	var arm_id = player_ref.equipped_armor
	var arm_data = ItemsDatabase.ITEMS.get(arm_id, {})
	var tier = arm_data.get("tier", 0)
	var lvl = player_ref.armor_upgrade

	var icon_tex = ItemsDatabase.get_item_icon(arm_id)
	if icon_tex: wpn_icon.texture = icon_tex
	wpn_name.text = "%s +%d" % [Localization.tr_text(arm_id), lvl]
	wpn_name.modulate = ItemsDatabase.get_tier_color(tier)

	var cur_hp = int(arm_data.get("hp_bonus", 0.0) + lvl * 40.0)
	var cur_def = int((arm_data.get("def", 0.0) + lvl * 0.02) * 100.0)
	wpn_stats.text = "Máu tối đa: +%d | Giảm sát thương: -%d%%" % [cur_hp, cur_def]

	for c in cost_container.get_children(): c.queue_free()

	if lvl >= player_ref.MAX_UPGRADE_LEVEL:
		next_stats.text = "Đã đạt cấp tối đa (+10)"
		next_stats.modulate = Color(1.0, 0.8, 0.2)
		btn_upgrade.text = "CẤP TỐI ĐA (+10)"
		btn_upgrade.disabled = true
		return

	var next_hp = cur_hp + 40
	var next_def = cur_def + 2
	next_stats.text = "Cấp tiếp theo (+%d): +%d HP | -%d%% ST (+2%% Giảm ST)" % [lvl + 1, next_hp, next_def]
	next_stats.modulate = Color(0.3, 0.9, 0.5)

	var need_stone = lvl + 1
	var need_dust = (lvl + 1) * 6
	var need_gem = max(0, lvl - 2)

	var has_stone = player_ref.inventory.get("mat_stone", 0)
	var has_dust = player_ref.inventory.get("mat_dust", 0)
	var has_gem = player_ref.inventory.get("mat_gem", 0)

	_add_cost_entry("mat_stone", has_stone, need_stone)
	_add_cost_entry("mat_dust", has_dust, need_dust)
	if need_gem > 0:
		_add_cost_entry("mat_gem", has_gem, need_gem)

	var can_upgrade = has_stone >= need_stone and has_dust >= need_dust and has_gem >= need_gem
	btn_upgrade.text = "CƯỜNG HÓA GIÁP (+%d)" % (lvl + 1)
	btn_upgrade.disabled = not can_upgrade

func _render_crafting_list() -> void:
	for c in craft_list.get_children(): c.queue_free()

	for recipe_id in ItemsDatabase.RECIPES.keys():
		var recipe = ItemsDatabase.RECIPES[recipe_id]
		var costs = recipe.get("costs", {})
		var result_data = ItemsDatabase.ITEMS.get(recipe_id, {})
		var result_tier = result_data.get("tier", 0)
		var item_type = result_data.get("type", -1)

		var card = PanelContainer.new()
		_apply_card_style(card)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		margin.add_child(hbox)

		var c_icon = TextureRect.new()
		c_icon.custom_minimum_size = Vector2(44, 44)
		c_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		c_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var w_tex = ItemsDatabase.get_item_icon(recipe_id)
		if w_tex: c_icon.texture = w_tex
		hbox.add_child(c_icon)

		var info_col = VBoxContainer.new()
		info_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var title_lbl = Label.new()
		title_lbl.text = Localization.tr_text(recipe_id)
		title_lbl.modulate = ItemsDatabase.get_tier_color(result_tier)
		info_col.add_child(title_lbl)

		var stat_lbl = Label.new()
		if item_type == ItemsDatabase.ItemType.WEAPON:
			stat_lbl.text = "%s: %d-%d | %s: %.1f/s" % [
				Localization.tr_text("lbl_atk"),
				result_data.get("min_atk", 0),
				result_data.get("max_atk", 0),
				Localization.tr_text("lbl_spd"),
				result_data.get("spd", 1.0)
			]
		elif item_type == ItemsDatabase.ItemType.ARMOR:
			var hp_b = int(result_data.get("hp_bonus", 0.0))
			var def_pct = int(result_data.get("def", 0.0) * 100.0)
			stat_lbl.text = "Máu tối đa: +%d | Giảm sát thương: -%d%%" % [hp_b, def_pct]
		elif item_type == ItemsDatabase.ItemType.ACCESSORY:
			var mp_b = int(result_data.get("mp_bonus", 0.0))
			var mp_r = result_data.get("mp_regen", 0.0)
			var crit_pct = int(result_data.get("crit", 0.0) * 100.0)
			stat_lbl.text = "Năng lượng: +%d | Hồi MP: +%.1f/s | Chí mạng: +%d%%" % [mp_b, mp_r, crit_pct]
		stat_lbl.modulate = Color(0.8, 0.85, 0.95, 0.8)
		info_col.add_child(stat_lbl)

		# Cost list inline
		var cost_str = "Cần: "
		var can_craft = true
		for mat in costs.keys():
			var req = costs[mat]
			var owned = player_ref.inventory.get(mat, 0)
			cost_str += "%s %d/%d  " % [Localization.tr_text(mat), owned, req]
			if owned < req: can_craft = false

		if not player_ref.can_accept_item(recipe_id):
			can_craft = false
			cost_str += " [Túi đầy!]"

		var req_lbl = Label.new()
		req_lbl.text = cost_str
		req_lbl.modulate = Color(0.4, 1.0, 0.5) if can_craft else Color(1.0, 0.45, 0.45)
		info_col.add_child(req_lbl)

		hbox.add_child(info_col)

		var craft_btn = Button.new()
		craft_btn.text = Localization.tr_text("btn_craft")
		craft_btn.custom_minimum_size = Vector2(90, 36)
		craft_btn.disabled = not can_craft
		var cur_id = recipe_id
		craft_btn.pressed.connect(func():
			if player_ref.craft_item(cur_id):
				_refresh_ui()
		)
		hbox.add_child(craft_btn)

		craft_list.add_child(card)

func _on_player_mana_changed(cur: float, max_val: float) -> void:
	if player_mp_bar:
		player_mp_bar.max_value = max_val
		player_mp_bar.value = cur
	if player_mp_label:
		player_mp_label.text = "%d / %d" % [int(cur), int(max_val)]

func _add_cost_entry(id: String, owned: int, required: int) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(24, 24)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = ItemsDatabase.get_item_icon(id)
	if tex: icon_rect.texture = tex
	row.add_child(icon_rect)

	var lbl = Label.new()
	lbl.text = "%s: %d / %d" % [Localization.tr_text(id), owned, required]
	lbl.modulate = Color(0.4, 1.0, 0.4) if owned >= required else Color(1.0, 0.4, 0.4)
	row.add_child(lbl)

	cost_container.add_child(row)

func _apply_card_style(panel: PanelContainer) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.18, 0.95)
	style.border_color = Color(0.3, 0.3, 0.45, 0.8)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	panel.add_theme_stylebox_override("panel", style)

func _on_boss_skill_announced(skill_id: String) -> void:
	var skill_key = "skill_" + skill_id
	var skill_name = Localization.tr_text(skill_key)
	var warn_label = Localization.tr_text("skill_warning")
	skill_warning.text = "%s: %s" % [warn_label, skill_name]
	warning_banner.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_pulse_warning()

func _on_boss_phase_broken(_phase: int) -> void:
	var broken_txt = Localization.tr_text("boss_phase_broken")
	var enraged_txt = Localization.tr_text("boss_enraged")
	skill_warning.text = "%s - %s" % [broken_txt, enraged_txt]
	warning_banner.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_pulse_warning(2.0)

func _pulse_warning(duration: float = 1.3) -> void:
	if warning_tween and warning_tween.is_valid():
		warning_tween.kill()
	warning_banner.visible = true
	warning_banner.modulate.a = 1.0
	warning_tween = create_tween()
	warning_tween.tween_interval(0.6)
	warning_tween.tween_property(warning_banner, "modulate:a", 0.0, duration - 0.6)
	warning_tween.tween_callback(func(): warning_banner.visible = false)

func _on_player_health_changed(cur: float, max_val: float) -> void:
	player_hp_bar.max_value = max_val
	player_hp_bar.value = cur
	if player_hp_label:
		player_hp_label.text = "%d / %d" % [int(cur), int(max_val)]

func _on_dps_updated(leaderboard: Array) -> void:
	var txt = "DPS: "
	for i in range(min(2, leaderboard.size())):
		var e = leaderboard[i]
		var dps_val = int(e["dps"])
		txt += "%s (%d/s)  " % [Localization.tr_text(e["name"]), dps_val]
	dps_info.text = txt

func _on_server_status_changed(is_online: bool) -> void:
	if not server_status_label: return
	if is_online:
		server_status_label.text = "🟢 CỔNG 8787 TRỰC TUYẾN"
		server_status_label.modulate = Color(0.3, 1.0, 0.6)
	else:
		server_status_label.text = "⚪ NGOẠI TUYẾN (OFFLINE)"
		server_status_label.modulate = Color(0.7, 0.7, 0.75)

func _on_network_leaderboard_updated(_ranks: Array) -> void:
	if current_tab == "leaderboard" and modal_root.visible:
		_refresh_leaderboard()

func _refresh_leaderboard() -> void:
	if not leaderboard_list: return
	for c in leaderboard_list.get_children(): c.queue_free()

	var ranks = NetworkManager.cached_leaderboard
	if ranks.is_empty():
		ranks = NetworkManager.DEFAULT_LEADERBOARD

	var my_name = Localization.tr_text("player_hero")
	for entry in ranks:
		var rank_idx = int(entry.get("rank", 1))
		var pname = entry.get("name", "Unknown")
		var floor_lvl = int(entry.get("floor", 1))
		var dps_val = int(entry.get("maxDps", 0))

		var card = PanelContainer.new()
		_apply_card_style(card)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		margin.add_child(hbox)

		var rank_lbl = Label.new()
		rank_lbl.custom_minimum_size = Vector2(48, 0)
		if rank_idx == 1:
			rank_lbl.text = "🥇 #1"
			rank_lbl.modulate = Color(1.0, 0.85, 0.2)
		elif rank_idx == 2:
			rank_lbl.text = "🥈 #2"
			rank_lbl.modulate = Color(0.85, 0.9, 1.0)
		elif rank_idx == 3:
			rank_lbl.text = "🥉 #3"
			rank_lbl.modulate = Color(1.0, 0.65, 0.4)
		else:
			rank_lbl.text = "   #%d" % rank_idx
			rank_lbl.modulate = Color(0.7, 0.75, 0.85)
		hbox.add_child(rank_lbl)

		var name_lbl = Label.new()
		name_lbl.text = pname
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if pname == my_name or pname == "Dũng Sĩ Hư Không" or pname == "Dũng Sĩ":
			name_lbl.modulate = Color(0.4, 1.0, 0.6)
			name_lbl.text += " (Bạn)"
		hbox.add_child(name_lbl)

		var floor_lbl = Label.new()
		floor_lbl.text = "Tầng: %d" % floor_lvl
		floor_lbl.modulate = Color(1.0, 0.85, 0.45)
		hbox.add_child(floor_lbl)

		var dps_lbl = Label.new()
		dps_lbl.custom_minimum_size = Vector2(120, 0)
		dps_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		dps_lbl.text = "DPS: %d/s" % dps_val
		dps_lbl.modulate = Color(0.4, 0.9, 1.0)
		hbox.add_child(dps_lbl)

		leaderboard_list.add_child(card)

