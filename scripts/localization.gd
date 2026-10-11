extends Node

# ponytail: simple dictionary localization table

const STRINGS: Dictionary = {
	# Boss & Floors
	"boss_name": "QUÁI VẬT VĨNH CỬU",
	"boss_phase": "TẦNG",
	"boss_phase_broken": "ĐÃ PHÁ VỠ TẦNG MÁU!",
	"boss_enraged": "QUÁI VẬT CUỒNG BẠO!",
	"skill_warning": "CẢNH BÁO",
	"skill_chaos_spiral": "Bão Đạn Hỗn Loạn",
	"skill_void_beam": "Tia Sáng Hư Không",
	"skill_meteor_storm": "Mưa Thiên Thạch",
	"skill_gravity_vortex": "Vực Xoáy Trọng Lực",
	"skill_shockwave": "Chấn Động Địa Chấn",
	"skill_dimensional_cleave": "Vết Chém Không Gian",
	"skill_abyssal_orbs": "Quả Cầu Vực Thẳm",
	"skill_apocalypse_barrage": "Mưa Đạn Tận Thế",

	"floor_1_title": "TẦNG 1: HẦM NGỤC HƯ KHÔNG",
	"floor_2_title": "TẦNG 2: ĐẦM LẦY YÊU MA",
	"floor_3_title": "TẦNG 3: ĐẤU TRƯỜNG ORC",
	"floor_4_title": "TẦNG 4: MÊ CUNG MINOTAUR",

	# Monsters
	"monster_skeleton": "Bộ Xương Chiến Binh",
	"monster_zombie": "Xác Sống Độc Dược",
	"monster_goblin": "Yêu Tinh Sát Thủ",
	"monster_orc": "Orc Cuồng Nộ",
	"monster_minotaur": "Quỷ Ngưu Minotaur",

	# Player & Skills
	"player_name": "Dũng Sĩ",
	"skill_q": "Toàn Phong",
	"skill_e": "Trảm Hồn",
	"skill_r": "Thần Kiếm",
	"skill_dash": "Lướt",
	"skill_aegis": "Thánh Khiên",
	"skill_lightning": "Lôi Phạt",
	"weapon": "Vũ khí",
	"stone": "Đá cường hóa",
	"dust": "Bụi hư không",
	"btn_bag": "Balo / Lò Rèn",
	"btn_upgrade": "Cường hóa vũ khí (+%d)",
	"btn_open": "Mở Rương",
	"btn_equip": "Trang Bị",
	"btn_equipped": "[ Đang Dùng ]",
	"btn_craft": "Rèn / Chế Tạo",
	"btn_close": "Đóng [X]",
	"tab_bag": "Kho Đồ",
	"tab_forge": "Lò Rèn",
	"bag_title": "BALO & LÒ RÈN",
	"dash_hint": "Shift: Lướt né đòn (Kháng sát thương)",
	"lbl_atk": "Sát thương",
	"lbl_spd": "Tốc độ đánh",
	"lbl_forge_current": "Vũ Khí Hiện Tại",
	"lbl_forge_upgrade": "CƯỜNG HÓA VŨ KHÍ",
	"lbl_forge_craft": "RÈN VŨ KHÍ CAO CẤP",
	"lbl_cost": "Nguyên liệu yêu cầu:",
	"lbl_crafted_success": "Chế tạo thành công!",
	"lbl_max_level": "Đã đạt cấp tối đa",
	"desc_chest": "Chứa trang bị, linh thạch và đá cường hóa quý giá",
	"desc_mat": "Vật phẩm dùng để cường hóa và rèn trang bị",

	# Items
	"mat_dust": "Bụi Hư Không",
	"mat_gem": "Linh Thạch",
	"mat_stone": "Đá Cường Hóa",
	"mat_shard": "Mảnh Vĩnh Cửu",
	"item_heal_potion": "Bình Máu Thánh (+250 HP)",
	"heal_orb": "Ngọc Sinh Mệnh (+250 HP)",
	"wpn_sword_1": "Đoản Kiếm Thép",
	"wpn_sword_2": "Song Huyết Trảm",
	"wpn_sword_3": "Thiên Lôi Kiếm",
	"wpn_sword_4": "Hư Không Đao",
	"wpn_sword_5": "Trảm Tinh Thần Kiếm",
	"chest_wood": "Rương Gỗ",
	"chest_silver": "Rương Bạc",
	"chest_gold": "Rương Vàng",
	"chest_mythic": "Rương Thần Thoại",

	# Armors
	"arm_leather_1": "Giáp Da Thô",
	"arm_plate_2": "Thiết Giáp Chiến Binh",
	"arm_dragon_3": "Long Lân Khôi Giáp",
	"arm_void_4": "Chiến Giáp Hư Không",

	# Rings & Accessories
	"ring_copper_1": "Nhẫn Đồng Thô",
	"ring_silver_2": "Nhẫn Bạc Linh Hoạt",
	"ring_ruby_3": "Nhẫn Huyết Ngọc",
	"ring_void_4": "Nhẫn Vực Thẳm Vĩnh Cửu",

	# Stats & Limits
	"lbl_def": "Giảm sát thương",
	"lbl_max_hp_bonus": "Máu",
	"lbl_max_mp_bonus": "Năng lượng",
	"lbl_mp_regen": "Hồi MP",
	"lbl_crit_bonus": "Chí mạng",
	"lbl_slot_weapon": "Vũ Khí",
	"lbl_slot_armor": "Giáp Trụ",
	"lbl_slot_ring": "Bùa / Nhẫn",
	"lbl_capacity": "Túi đồ: %d / %d ô",
	"lbl_bag_full": "Túi đồ đã đầy!",
	"lbl_not_enough_mp": "Không đủ Năng Lượng!",
	"lbl_upgrade_armor": "Cường hóa giáp (+%d)",

	# Game Branding & Title
	"game_title": "VỰC THẲM VĨNH CỬU",
	"game_subtitle": "DI SẢN HƯ KHÔNG (VOID'S LEGACY)",
	"player_hero": "Dũng Sĩ Hư Không",

	# Leaderboard & Backend
	"tab_leaderboard": "Bảng Xếp Hạng",
	"server_online": "Trực Tuyến (Online)",
	"server_offline": "Ngoại Tuyến (Offline)",
	"lbl_rank": "Hạng",
	"lbl_player": "Chiến Binh",
	"lbl_floor_record": "Tầng Cao Nhất",
	"lbl_max_dps": "DPS Đỉnh Điểm",
	"lbl_sync_success": "Đã đồng bộ đám mây!"
}

func tr_text(key: String) -> String:
	if STRINGS.has(key):
		return STRINGS[key]
	var lower = key.to_lower()
	if STRINGS.has(lower):
		return STRINGS[lower]
	return key
