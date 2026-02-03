extends RigidBody2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound




func _on_hit_box_damaged(hurt_box: HurtBox) -> void:
	queue_free()
