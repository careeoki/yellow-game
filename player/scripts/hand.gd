class_name PlayerHand extends CharacterBody2D
@onready var body: Player = $".."

@onready var arm_sprite: Line2D = $"../../ArmSprite"
@onready var grab_area: Area2D = $GrabArea
@onready var hand_pin: PinJoint2D = $"../../HandPin"
@onready var pos_test: ColorRect = $"../../PosTest"
@onready var attach_point: Marker2D = $AttachPoint

var pin_joint: PinJoint2D = null
var grabbed_object: RigidBody2D = null
var object_initial_rotation

func _physics_process(delta: float) -> void:
	var hand_velocity: Vector2 = get_global_mouse_position() - global_position
	if hand_velocity.length() > 1500:
		hand_velocity = hand_velocity.normalized() * 1500
	if position.length() > 400:
		position = position.normalized() * 400
	velocity = hand_velocity * 3
	look_at(body.position)
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var push_force = (15 * velocity.length() / 1000) + 10
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	arm_sprite.set_point_position(0, get_parent().global_position)
	arm_sprite.set_point_position(1, global_position)
	grab_handling()
	body.get_angle_to(position)


func grab_handling():
	var grabbables = grab_area.get_overlapping_bodies()
	if Input.is_action_just_pressed("grab"):
		if grabbed_object == null:
			if grabbables.size() > 0:
				enter_grab(grabbables[0])
		else:
			exit_grab()
	if grabbed_object != null:
		var grab_velocity: Vector2 = attach_point.global_position - grabbed_object.global_position
		grabbed_object.apply_force(grab_velocity * 1000)
		#print(grab_velocity)
		grabbed_object.rotation = rotation
		#pos_test.global_position = grabbed_object.get_child(0).global_position
		#if grabbed_object.get_child(0).global_position.distance_to(attach_point.global_position) > 256:
			#exit_grab()
		pass
			
func enter_grab(new_object):
	grabbed_object = new_object
	grabbed_object.linear_damp = 100
	#set_collision_layer_value(1, false)
	#set_collision_mask_value(3, false)
	grabbed_object.set_collision_layer_value(3, false)
	grabbed_object.set_collision_layer_value(4, true)
	grabbed_object.set_collision_mask_value(1, false)
	object_initial_rotation = grabbed_object.rotation
	#create_pin_joint()
	

func exit_grab():
	grabbed_object.linear_damp = 0
	grabbed_object.angular_damp = 0
	#set_collision_layer_value(1, true)
	#set_collision_mask_value(3, true)
	grabbed_object.set_collision_layer_value(3, true)
	grabbed_object.set_collision_layer_value(4, false)
	grabbed_object.set_collision_mask_value(1, true)
	grabbed_object = null
	#remove_pin_joint()


func create_pin_joint():
	if pin_joint == null:
		pin_joint = PinJoint2D.new()
		get_parent().get_parent().get_parent().add_child(pin_joint)
	grabbed_object.global_position = attach_point.global_position
	pin_joint.bias = 0.9
	pin_joint.node_a = self.get_path()
	pin_joint.node_b = grabbed_object.get_path()
	

func remove_pin_joint():
	pin_joint.node_a = ""
	pin_joint.node_b = ""
