class_name HurtBox extends Area2D

@export var damage: int = 1


func _ready() -> void:
	area_entered.connect(hit_box_entered)

func hit_box_entered(area: Area2D) -> void:
	if area is HitBox:
		area.take_damage(damage, get_parent())
