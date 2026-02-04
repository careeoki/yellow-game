class_name HitBox extends Area2D

signal Damaged(hurt_box: HurtBox)

func take_damage(hurt_box: HurtBox) -> void:
	if hurt_box.get_parent() == GrabObject:
		if abs(hurt_box.get_parent().linear_velocity.x) > 200 or abs(hurt_box.get_parent().linear_velocity.y) > 200:
			Damaged.emit(hurt_box)
	else:
		Damaged.emit(hurt_box)
