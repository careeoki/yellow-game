class_name HurtBox extends Area2D

@export var damage: int = 1
@export var dynamic_knockback: bool = true
@export var knockback: float = 1000


func _ready() -> void:
	area_entered.connect(hit_box_entered)

func hit_box_entered(area: Area2D) -> void:
	if area is HitBox:
		area.take_damage(self)
