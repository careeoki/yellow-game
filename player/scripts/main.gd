class_name Player extends CharacterBody2D

signal health_changed(_health)

var max_health: int = 100
var health: int = 100
var direction : Vector2 = Vector2.ZERO

var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0
var invulnerable: bool = false

@onready var leg_sprite: AnimatedSprite2D = $LegSprite
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var eat_sound: AudioStreamPlayer2D = $EatSound
@onready var hand: PlayerHand = $Hand

var blood = preload("res://particles/blood.tscn")
var SMALL_BLOOD = preload("res://particles/small_blood.tscn")
const move_speed = 1000.0
const acceleration = 15
var last_hurt_box: HurtBox = null

#func _ready() -> void:
	#PlayerManager.player = self

func get_direction():
	if health > 0:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		return direction.normalized()
	else:
		direction = Vector2.ZERO
		return direction


func _physics_process(delta: float) -> void:
	if knockback_time > 0.0:
		if not invulnerable:
			invulnerable = true
		velocity = knockback
		velocity = lerp(velocity, Vector2.ZERO, delta * 10)
		knockback_time -= delta
		if knockback_time <= 0.0:
			knockback = Vector2.ZERO
	else:
		if invulnerable:
			invulnerable = false
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
	if invulnerable:
		return
	last_hurt_box = hurt_box
	if hurt_box.dynamic_knockback:
		if abs(hurt_box.get_parent().linear_velocity.x) > 200 or abs(hurt_box.get_parent().linear_velocity.y) > 200:
			if hurt_box.get_parent() != hand.grabbed_object:
				create_blood()
				hurt_sound.play()
				update_health(-hurt_box.damage)
				var knockback_direction = (hurt_box.global_position - global_position).normalized()
				var knockback_velocity = (hurt_box.get_parent().linear_velocity.length() * 0.5) + 100
				apply_knockback(knockback_direction, knockback_velocity, 0.15)
				print(health)
	else:
		create_blood()
		hurt_sound.play()
		update_health(-hurt_box.damage)
		var knockback_direction = (hurt_box.global_position - global_position).normalized()
		apply_knockback(knockback_direction, hurt_box.knockback, 0.15)

func update_health(delta: int):
	health = clampi(health + delta, 0, max_health)
	health_changed.emit(health)
	if health == 0:
		die()

func die():
	if hand.grabbed_object:
		hand.exit_grab()

func create_blood():
	var blood_instance = blood.instantiate()
	var small_blood_instance = SMALL_BLOOD.instantiate()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	get_tree().current_scene.add_child(small_blood_instance)
	small_blood_instance.global_position = global_position

func apply_knockback(dir: Vector2, force: float, duration: float) -> void:
	knockback = -dir * force
	knockback_time = duration
	
