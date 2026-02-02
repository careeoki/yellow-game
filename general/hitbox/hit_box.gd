class_name HitBox extends Area2D

signal Damaged(damage: int, object)

func take_damage(damage: int, object) -> void:
	if abs(object.linear_velocity.x) > 200 or abs(object.linear_velocity.y) > 200:
		print("took ", damage, " damage")
		Damaged.emit(damage, object)
