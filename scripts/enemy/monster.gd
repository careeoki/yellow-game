extends RigidBody2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound




func _on_hit_box_damaged(damage: int, object) -> void:
	queue_free()
