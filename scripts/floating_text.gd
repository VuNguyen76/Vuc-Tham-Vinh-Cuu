extends Node2D

# FloatingText.gd - Eternal Void Colossus (QVVC)
# Floating damage numbers and loot notification popups

@onready var label: Label = $Label

var velocity: Vector2 = Vector2.ZERO
var duration: float = 0.85
var timer: float = 0.0

func setup(text: String, color: Color, font_size: int = 18, is_crit: bool = false) -> void:
	if not is_node_ready(): await ready
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", font_size)

	if is_crit:
		scale = Vector2(1.4, 1.4)
		velocity = Vector2(randf_range(-40, 40), -140.0)
	else:
		scale = Vector2(1.0, 1.0)
		velocity = Vector2(randf_range(-25, 25), -90.0)

func _process(delta: float) -> void:
	timer += delta
	position += velocity * delta
	velocity.y += 110.0 * delta # Gentle gravity
	
	# Fade out
	var alpha = 1.0 - (timer / duration)
	modulate.a = clamp(alpha, 0.0, 1.0)

	if timer >= duration:
		queue_free()
