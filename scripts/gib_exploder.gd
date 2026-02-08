extends Node2D

func _ready() -> void:
	for c in get_children():
		var random: Vector2
		random.x = randf_range(-6000, 6000)
		random.y = randf_range(-6000, 6000)
		c.apply_impulse(random)
