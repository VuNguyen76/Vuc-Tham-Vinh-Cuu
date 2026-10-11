extends Node

# ponytail: minimal data-driven items and drop math

enum Tier { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }
enum ItemType { WEAPON, ARMOR, ACCESSORY, MATERIAL, CHEST }

const ITEMS: Dictionary = {
	"mat_dust": { "name": "Void Dust", "type": ItemType.MATERIAL, "tier": Tier.COMMON },
	"mat_gem": { "name": "Spirit Gem", "type": ItemType.MATERIAL, "tier": Tier.UNCOMMON },
	"mat_stone": { "name": "Enhance Stone", "type": ItemType.MATERIAL, "tier": Tier.RARE },
	"mat_shard": { "name": "Eternal Shard", "type": ItemType.MATERIAL, "tier": Tier.LEGENDARY },
	"item_heal_potion": { "name": "Bình Máu Thánh", "type": ItemType.MATERIAL, "tier": Tier.UNCOMMON, "heal": 250.0 },
	"heal_orb": { "name": "Ngọc Sinh Mệnh", "type": ItemType.MATERIAL, "tier": Tier.UNCOMMON, "heal": 250.0 },

	"wpn_sword_1": { "name": "Steel Dagger", "type": ItemType.WEAPON, "tier": Tier.COMMON, "min_atk": 25, "max_atk": 40, "spd": 1.0 },
	"wpn_sword_2": { "name": "Blood Crescent", "type": ItemType.WEAPON, "tier": Tier.UNCOMMON, "min_atk": 65, "max_atk": 95, "spd": 1.3 },
	"wpn_sword_3": { "name": "Thunder Blade", "type": ItemType.WEAPON, "tier": Tier.RARE, "min_atk": 160, "max_atk": 230, "spd": 1.2 },
	"wpn_sword_4": { "name": "Void Cleaver", "type": ItemType.WEAPON, "tier": Tier.EPIC, "min_atk": 380, "max_atk": 540, "spd": 1.4 },
	"wpn_sword_5": { "name": "Star Destroyer", "type": ItemType.WEAPON, "tier": Tier.MYTHIC, "min_atk": 1200, "max_atk": 1800, "spd": 2.0 },

	# Armors (HP bonus + % Damage Reduction)
	"arm_leather_1": { "name": "Leather Armor", "type": ItemType.ARMOR, "tier": Tier.COMMON, "hp_bonus": 100.0, "def": 0.06 },
	"arm_plate_2": { "name": "Plate Armor", "type": ItemType.ARMOR, "tier": Tier.UNCOMMON, "hp_bonus": 250.0, "def": 0.14 },
	"arm_dragon_3": { "name": "Dragon Armor", "type": ItemType.ARMOR, "tier": Tier.EPIC, "hp_bonus": 600.0, "def": 0.24 },
	"arm_void_4": { "name": "Void Armor", "type": ItemType.ARMOR, "tier": Tier.MYTHIC, "hp_bonus": 1200.0, "def": 0.36 },

	# Accessories / Rings (MP bonus, MP regen, Crit rate)
	"ring_copper_1": { "name": "Copper Ring", "type": ItemType.ACCESSORY, "tier": Tier.COMMON, "mp_bonus": 25.0, "mp_regen": 2.0, "crit": 0.02 },
	"ring_silver_2": { "name": "Silver Ring", "type": ItemType.ACCESSORY, "tier": Tier.UNCOMMON, "mp_bonus": 50.0, "mp_regen": 4.5, "crit": 0.06 },
	"ring_ruby_3": { "name": "Ruby Ring", "type": ItemType.ACCESSORY, "tier": Tier.EPIC, "mp_bonus": 90.0, "mp_regen": 8.0, "crit": 0.12 },
	"ring_void_4": { "name": "Void Ring", "type": ItemType.ACCESSORY, "tier": Tier.MYTHIC, "mp_bonus": 160.0, "mp_regen": 14.0, "crit": 0.20 },

	"chest_wood": { "name": "Wooden Chest", "type": ItemType.CHEST, "tier": Tier.COMMON },
	"chest_silver": { "name": "Silver Chest", "type": ItemType.CHEST, "tier": Tier.RARE },
	"chest_gold": { "name": "Gold Chest", "type": ItemType.CHEST, "tier": Tier.EPIC },
	"chest_mythic": { "name": "Mythic Chest", "type": ItemType.CHEST, "tier": Tier.MYTHIC }
}

const RECIPES: Dictionary = {
	"wpn_sword_2": {
		"result": "wpn_sword_2",
		"costs": { "mat_gem": 8, "mat_stone": 4 }
	},
	"wpn_sword_3": {
		"result": "wpn_sword_3",
		"costs": { "mat_gem": 20, "mat_stone": 12 }
	},
	"wpn_sword_4": {
		"result": "wpn_sword_4",
		"costs": { "mat_shard": 1, "mat_stone": 25 }
	},
	"wpn_sword_5": {
		"result": "wpn_sword_5",
		"costs": { "mat_shard": 3, "mat_stone": 50 }
	},
	"arm_plate_2": {
		"result": "arm_plate_2",
		"costs": { "mat_stone": 6, "mat_gem": 6 }
	},
	"arm_dragon_3": {
		"result": "arm_dragon_3",
		"costs": { "mat_stone": 20, "mat_shard": 1 }
	},
	"arm_void_4": {
		"result": "arm_void_4",
		"costs": { "mat_stone": 45, "mat_shard": 3 }
	},
	"ring_silver_2": {
		"result": "ring_silver_2",
		"costs": { "mat_gem": 12, "mat_dust": 30 }
	},
	"ring_ruby_3": {
		"result": "ring_ruby_3",
		"costs": { "mat_gem": 35, "mat_shard": 1 }
	},
	"ring_void_4": {
		"result": "ring_void_4",
		"costs": { "mat_shard": 3, "mat_stone": 30 }
	}
}

func get_tier_color(tier: int) -> Color:
	match tier:
		Tier.COMMON: return Color(0.7, 0.75, 0.8)
		Tier.UNCOMMON: return Color(0.25, 0.85, 0.45)
		Tier.RARE: return Color(0.25, 0.65, 1.0)
		Tier.EPIC: return Color(0.75, 0.35, 0.95)
		Tier.LEGENDARY: return Color(1.0, 0.8, 0.2)
		Tier.MYTHIC: return Color(1.0, 0.25, 0.4)
	return Color.WHITE

func get_item_icon(id: String) -> Texture2D:
	var path = "res://assets/icons/%s.png" % id
	if ResourceLoader.exists(path):
		return load(path)
	return null

func calculate_hit_loot(damage: float, is_crit: bool, luck: float = 1.0) -> Array:
	var drops: Array = []
	var dust_chance = clamp(0.25 + (damage / 500.0) * 0.25, 0.0, 0.95) * luck
	if randf() < dust_chance:
		drops.append({ "id": "mat_dust", "amount": maxi(1, int(damage / 100.0)) })

	if is_crit or damage >= 200.0:
		if randf() < (0.2 * luck):
			drops.append({ "id": "mat_gem", "amount": 1 })

	if damage >= 400.0 and randf() < (0.15 * luck):
		drops.append({ "id": "mat_stone", "amount": 1 })

	if damage >= 800.0 and randf() < (0.05 * luck):
		drops.append({ "id": "wpn_sword_3", "amount": 1 })

	return drops

func check_milestone_chests(prev_dmg: float, new_dmg: float) -> Array:
	var milestones = [
		[5000.0, "chest_wood"],
		[30000.0, "chest_silver"],
		[150000.0, "chest_gold"],
		[1000000.0, "chest_mythic"]
	]
	var chests: Array = []
	for m in milestones:
		if prev_dmg < m[0] and new_dmg >= m[0]:
			chests.append(m[1])
	return chests

func open_chest(chest_id: String) -> Array:
	match chest_id:
		"chest_wood":
			return [
				{ "id": "mat_dust", "amount": 20 },
				{ "id": "mat_stone", "amount": 2 },
				{ "id": "arm_leather_1", "amount": 1 }
			]
		"chest_silver":
			return [
				{ "id": "mat_gem", "amount": 10 },
				{ "id": "mat_stone", "amount": 4 },
				{ "id": "wpn_sword_2", "amount": 1 },
				{ "id": "ring_silver_2", "amount": 1 }
			]
		"chest_gold":
			return [
				{ "id": "mat_stone", "amount": 10 },
				{ "id": "mat_gem", "amount": 25 },
				{ "id": "arm_dragon_3", "amount": 1 },
				{ "id": "ring_ruby_3", "amount": 1 }
			]
		"chest_mythic":
			return [
				{ "id": "mat_shard", "amount": 3 },
				{ "id": "mat_stone", "amount": 20 },
				{ "id": "wpn_sword_5", "amount": 1 },
				{ "id": "arm_void_4", "amount": 1 }
			]
	return []
