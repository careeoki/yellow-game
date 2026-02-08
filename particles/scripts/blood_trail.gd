extends Node2D
@export var blood_rate: float = 0.03
@onready var timer: Timer = $Timer


const BLOOD_DROP = preload("res://particles/blood_drop.tscn")


func _ready() -> void:
	timer.wait_time = blood_rate
	timer.start()

func _on_timer_timeout() -> void:
	var blood_instance = BLOOD_DROP.instantiate()
	var rand: float
	get_tree().current_scene.call_deferred("add_child", blood_instance)
	blood_instance.global_position = global_position
	rand = randf_range(0.4, 1.2)
	blood_instance.scale = Vector2(rand, rand)
	if get_parent().linear_velocity.length() > 200:
		timer.start()
