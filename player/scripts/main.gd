class_name Player extends CharacterBody2D

var max_health: int = 100
var health: int = 100
var direction : Vector2 = Vector2.ZERO

var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0


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


func _physics_process(delta: float) -> void:
	if knockback_time > 0.0:
		velocity = knockback
		knockback_time -= delta
		if knockback_time <= 0.0:
			knockback = Vector2.ZERO
	else:
		velocity = lerp(velocity, get_direction() * move_speed, delta * acceleration)
	
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
			

func _on_hit_box_damaged(hurt_box: HurtBox) -> void:
	if hurt_box.get_parent() != hand.grabbed_object:
		var blood_instance = blood.instantiate()
		get_tree().current_scene.add_child(blood_instance)
		blood_instance.global_position = global_position
		hurt_sound.play()
		update_health(-hurt_box.damage)
		var knockback_direction = (hurt_box.global_position - global_position).normalized()
		apply_knockback(knockback_direction, hurt_box.knockback, 0.1)
		print(health)

func update_health(delta: int):
	health = clampi(health + delta, 0, max_health)

func apply_knockback(_direction: Vector2, force: float, duration: float) -> void:
	knockback = direction * force
	knockback_time = duration
	
