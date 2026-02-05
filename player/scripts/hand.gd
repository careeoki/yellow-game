class_name PlayerHand extends CharacterBody2D
@onready var body: Player = $".."

@onready var player: Player = $".."
@onready var arm_sprite: Sprite2D = $"../ArmSprite"
@onready var grab_area: Area2D = $GrabArea
@onready var attach_point: Marker2D = $AttachPoint
@onready var final_position: ColorRect = $"../FinalPosition"
@onready var hand_sprite: AnimatedSprite2D = $"../HandSprite"
@onready var grab_look_at: Marker2D = $"../GrabLookAt"
@onready var far_look_at: Marker2D = $"../GrabLookAt/FarLookAt"
@onready var hat_attach_point: Marker2D = $"../HatAttachPoint"
@onready var slip_sound: AudioStreamPlayer2D = $SlipSound


var pin_joint: PinJoint2D = null
var spring: DampedSpringJoint2D = null
var grabbed_object: GrabObject = null
var hat_object: GrabObject = null
var hand_velocity: Vector2
var max_reach_round = 429


func _physics_process(_delta: float) -> void:
	final_position.global_position = get_global_mouse_position()
	if final_position.position.length() > 600:
		final_position.position = final_position.position.normalized() * 600
	#if final_position.position.length() < 100:
		#final_position.position = final_position.position.normalized() * 100
	#if grabbed_object:
		#hand_velocity = (grabbed_object.global_position - global_position) * 3
	#else:
	hand_velocity = final_position.global_position - global_position
	
	if hand_velocity.length() > 1800:
		hand_velocity = hand_velocity.normalized() * 1800
	if position.length() > 400:
		position = position.normalized() * 400
	velocity = hand_velocity * 10
	look_at(body.position)
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var push_force = (15 * velocity.length() / 1000) + 15
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	grab_handling()
	body.get_angle_to(position)
	
	if !grabbed_object:
		hand_sprite.global_position = global_position
	else:
		hand_sprite.global_position = grabbed_object.global_position
	hand_sprite.look_at(body.position)
	grab_look_at.look_at(final_position.global_position)
	arm_sprite.look_at(hand_sprite.global_position)
	arm_sprite.scale = Vector2(round(hand_sprite.position.length()) / max_reach_round, 1)
	print(round(hand_sprite.position.length()) / max_reach_round, " ", round(position.length()))
	


func grab_handling():
	var grabbables = grab_area.get_overlapping_bodies()
	if Input.is_action_just_pressed("grab"):
		if grabbed_object == null:
			if grabbables.size() > 0:
				enter_grab(grabbables[0])
		else:
			exit_grab()
	if grabbed_object != null:
		var grab_velocity: Vector2 =  attach_point.global_position - grabbed_object.global_position
		grabbed_object.apply_force(grab_velocity * 120)
		grabbed_object.target_position = far_look_at.global_position
		
		if grabbed_object.get_child(0).global_position.distance_to(body.global_position) > 800:
			exit_grab()
			slip_sound.play()
		pass
			
func enter_grab(new_object):
	grabbed_object = new_object
	grabbed_object.reparent(player)
	grabbed_object.sprite.z_index = 2
	grabbed_object.linear_damp = 20
	grabbed_object.angular_damp = -1
	set_collision_layer_value(1, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(2, false)
	grabbed_object.set_collision_layer_value(3, false)
	grabbed_object.set_collision_layer_value(4, true)
	grabbed_object.set_collision_mask_value(1, false)

func exit_grab():
	global_position = grabbed_object.global_position
	grabbed_object.linear_damp = 0
	grabbed_object.angular_damp = 0
	
	set_collision_mask_value(2, true)
	if grabbed_object.equipable and get_global_mouse_position().distance_to(body.global_position) < 100:
		grabbed_object.equip(hat_attach_point)
		hat_object = grabbed_object
		grabbed_object = null
		return
	else:
		
		grabbed_object.reparent(get_tree().current_scene)
		grabbed_object.sprite.z_index = 0
		grabbed_object.set_collision_layer_value(3, true)
		grabbed_object.set_collision_layer_value(4, false)
		grabbed_object.set_collision_mask_value(1, true)
		grabbed_object.exit_grab()
		grabbed_object = null
		
	await get_tree().create_timer(0.1).timeout
	set_collision_layer_value(1, true)
	set_collision_mask_value(3, true)
