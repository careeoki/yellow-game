class_name Player extends CharacterBody2D

var health: int = 100
var direction : Vector2 = Vector2.ZERO
@onready var leg_sprite: AnimatedSprite2D = $LegSprite
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var hand: PlayerHand = $Hand

var blood = preload("res://particles/blood.tscn")
const move_speed = 900.0
const acceleration = 20

func get_direction():
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return direction.normalized()

func _process(delta: float) -> void:
	velocity = lerp(velocity, get_direction() * move_speed, delta * acceleration)
	pass


func _physics_process(delta: float) -> void:
	move_and_slide()
	if direction and leg_sprite.animation == "idle":
		leg_sprite.play("walk")
	elif not direction:
		leg_sprite.play("idle")
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var push_force = (15 * velocity.length() / move_speed) + 10
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
			


func _on_hit_box_damaged(damage: int, object) -> void:
	if object != hand.grabbed_object:
		var blood_instance = blood.instantiate()
		get_tree().current_scene.add_child(blood_instance)
		blood_instance.global_position = global_position
		hurt_sound.play()
		health -= damage
		print(health)
