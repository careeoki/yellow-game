extends AnimatedSprite2D
@onready var player: Player = $".."

var last_health: int = 100


func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	animation = "damage_states"
	frame = 0

func _on_health_changed(_health):
	if _health > 0:
		var new_frame = 9 - (_health / 10)
		if _health < last_health:
			last_health = _health
			animation = "hurt"
			await get_tree().create_timer(0.3).timeout
			animation = "damage_states"
			frame = new_frame
		elif _health > last_health:
			last_health = _health
			animation = "damage_states"
			frame = new_frame
	else:
		_health = last_health
		animation = "die"
