class_name PlayerHand extends CharacterBody2D

@onready var arm_sprite: Line2D = $"../../ArmSprite"
@onready var grab_area: Area2D = $GrabArea
@onready var hand_pin: PinJoint2D = $"../../HandPin"

var grabbed_object = null

func _physics_process(delta: float) -> void:
	var hand_velocity: Vector2 = get_global_mouse_position() - global_position
	if hand_velocity.length() > 1000:
		hand_velocity = hand_velocity.normalized() * 1500
	if position.length() > 400:
		position = position.normalized() * 400
	velocity = hand_velocity * 3
	look_at(get_global_mouse_position())
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var push_force = (15 * velocity.length() / 1000) + 10
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	arm_sprite.set_point_position(0, get_parent().global_position)
	arm_sprite.set_point_position(1, global_position)
	grab_handling()


func grab_handling():
	var grabbables = grab_area.get_overlapping_bodies()
	if Input.is_action_just_pressed("grab"):
		if grabbed_object == null:
			if grabbables.size() > 0:
				enter_grab(grabbables[0])
		else:
			exit_grab()
	if grabbed_object != null:
		var grab_velocity: Vector2 = global_position - grabbed_object.global_position
		grabbed_object.apply_force(grab_velocity * 400)
			
func enter_grab(new_object):
	grabbed_object = new_object
	grabbed_object.linear_damp = 20
	grabbed_object.set_collision_layer_value(3, false)
	grabbed_object.set_collision_mask_value(1, false)

func exit_grab():
	grabbed_object.linear_damp = 0
	grabbed_object.set_collision_layer_value(3, true)
	grabbed_object.set_collision_mask_value(1, true)
	grabbed_object = null
