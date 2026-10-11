extends Node

# NetworkManager.gd - Dedicated Client-Server Synchronizer
# Handles REST API communication with the Eternal Abyss backend:
# - Online/Offline auto-detection
# - Cloud profile sync & save
# - Global high-score leaderboard
# - World boss damage contribution

signal server_status_changed(online: bool)
signal cloud_save_synced(success: bool)
signal leaderboard_updated(entries: Array)

@export var server_url: String = "http://127.0.0.1:8787"

const DEFAULT_LEADERBOARD: Array = [
	{ "rank": 1, "name": "Vô Danh Kiếm Thánh", "floor": 10, "maxDps": 18450 },
	{ "rank": 2, "name": "Chiến Thần Hư Không", "floor": 8, "maxDps": 12800 },
	{ "rank": 3, "name": "Bá Vương Trảm Tinh", "floor": 7, "maxDps": 9400 },
	{ "rank": 4, "name": "Kỵ Sĩ Ánh Sáng", "floor": 6, "maxDps": 6700 },
	{ "rank": 5, "name": "Dũng Sĩ Hư Không", "floor": 4, "maxDps": 4200 },
	{ "rank": 6, "name": "Thợ Săn Hắc Ám", "floor": 3, "maxDps": 3100 },
	{ "rank": 7, "name": "Ma Đạo Sư Lôi Điện", "floor": 2, "maxDps": 2200 },
	{ "rank": 8, "name": "Đao Khách Sa Mạc", "floor": 2, "maxDps": 1850 },
	{ "rank": 9, "name": "Tân Binh Hư Không", "floor": 1, "maxDps": 1100 },
	{ "rank": 10, "name": "Lính Đánh Thuê", "floor": 1, "maxDps": 850 }
]

var is_online: bool = false
var player_uuid: String = ""
var player_name: String = "Dũng Sĩ Hư Không"
var auth_token: String = ""
var cached_leaderboard: Array = []

var http_health: HTTPRequest
var http_login: HTTPRequest
var http_save: HTTPRequest
var http_leaderboard: HTTPRequest

var ping_timer: float = 0.0
var auto_sync_timer: float = 0.0

func _ready() -> void:
	_load_or_generate_uuid()
	_setup_http_nodes()
	# Initial server handshake
	check_server_health()

func _load_or_generate_uuid() -> void:
	var path = "user://player_id.cfg"
	var config = ConfigFile.new()
	var err = config.load(path)
	if err == OK and config.has_section_key("player", "id"):
		player_uuid = config.get_value("player", "id")
		player_name = config.get_value("player", "name", "Dũng Sĩ Hư Không")
	else:
		player_uuid = "hero_%x%x" % [randi(), randi()]
		config.set_value("player", "id", player_uuid)
		config.set_value("player", "name", player_name)
		config.save(path)

func _setup_http_nodes() -> void:
	http_health = HTTPRequest.new()
	http_health.timeout = 2.0
	http_health.request_completed.connect(_on_health_completed)
	add_child(http_health)

	http_login = HTTPRequest.new()
	http_login.timeout = 3.0
	http_login.request_completed.connect(_on_login_completed)
	add_child(http_login)

	http_save = HTTPRequest.new()
	http_save.timeout = 3.0
	http_save.request_completed.connect(_on_save_completed)
	add_child(http_save)

	http_leaderboard = HTTPRequest.new()
	http_leaderboard.timeout = 3.0
	http_leaderboard.request_completed.connect(_on_leaderboard_completed)
	add_child(http_leaderboard)

func _process(delta: float) -> void:
	# Periodic ping every 10 seconds to detect server reconnection
	ping_timer += delta
	if ping_timer >= 10.0:
		ping_timer = 0.0
		check_server_health()

func check_server_health() -> void:
	if http_health.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		var url = "%s/api/status" % server_url
		http_health.request(url)

func _on_health_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var was_online = is_online
	if response_code == 200:
		is_online = true
		if not was_online:
			print("[NETWORK] Connected to Eternal Abyss server successfully!")
			server_status_changed.emit(true)
			_login_player()
			fetch_leaderboard()
	else:
		if is_online or not was_online:
			is_online = false
			server_status_changed.emit(false)

func _login_player() -> void:
	if not is_online: return
	var url = "%s/api/auth/login" % server_url
	var data = {
		"player_id": player_uuid,
		"name": player_name
	}
	var headers = ["Content-Type: application/json"]
	http_login.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_login_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.get("success", false):
			auth_token = json.get("token", "")
			print("[NETWORK] Authenticated as: ", json.get("player_id", player_uuid))

func sync_player_save(player_node: Node2D, floor_num: int, max_dps: float, total_dmg: float) -> void:
	if not is_online or not player_node: return
	var url = "%s/api/player/save" % server_url
	var payload = {
		"player_id": player_uuid,
		"name": player_name,
		"floor": floor_num,
		"weapon": player_node.get("equipped_weapon"),
		"weapon_upgrade": player_node.get("weapon_upgrade"),
		"armor": player_node.get("equipped_armor"),
		"armor_upgrade": player_node.get("armor_upgrade"),
		"ring": player_node.get("equipped_ring"),
		"inventory": player_node.get("inventory"),
		"max_dps": max_dps,
		"total_damage": total_dmg
	}
	var headers = ["Content-Type: application/json"]
	if http_save.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_save.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func _on_save_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		cloud_save_synced.emit(true)
		fetch_leaderboard()
	else:
		cloud_save_synced.emit(false)

func fetch_leaderboard() -> void:
	if not is_online: return
	if http_leaderboard.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		var url = "%s/api/leaderboard" % server_url
		http_leaderboard.request(url)

func _on_leaderboard_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("leaderboard"):
			cached_leaderboard = json["leaderboard"]
			leaderboard_updated.emit(cached_leaderboard)
