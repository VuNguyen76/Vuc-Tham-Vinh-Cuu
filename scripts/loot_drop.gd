extends Area2D

# ponytail: minimal loot drop with magnet pull

@export var item_id: String = "mat_dust"
@export var amount: int = 1

var target: Node2D = null

@onready var label: Label = $Label

func _ready() -> void:
	label.text = Localization.tr_text(item_id) + " x" + str(amount)

func _physics_process(delta: float) -> void:
	if not target:
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0: target = players[0]

	if target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist < 200.0:
			global_position = global_position.move_toward(target.global_position, delta * 350.0)
			if dist < 20.0:
				GameManager.item_collected.emit(item_id, amount)
				queue_free()
