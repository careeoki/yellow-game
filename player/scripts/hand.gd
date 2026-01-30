class_name PlayerHand extends CharacterBody2D
@onready var body: Player = $".."

@onready var arm_sprite: Line2D = $"../../ArmSprite"
@onready var grab_area: Area2D = $GrabArea
@onready var attach_static_body: StaticBody2D = $AttachStaticBody
@onready var grab_groove_joint: GrooveJoint2D = $AttachStaticBody/GrabGrooveJoint
@onready var final_position: ColorRect = $"../FinalPosition"
@onready var hand_sprite: Sprite2D = $"../HandSprite"


var pin_joint: PinJoint2D = null
var spring: DampedSpringJoint2D = null
var grabbed_object: Grab_Object = null
var object_initial_rotation
var hand_velocity: Vector2


func _physics_process(_delta: float) -> void:
	final_position.global_position = get_global_mouse_position()
	if final_position.position.length() > 600:
		final_position.position = final_position.position.normalized() * 600
	
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
	arm_sprite.set_point_position(0, get_parent().global_position)
	
	grab_handling()
	body.get_angle_to(position)
	
	if !grabbed_object:
		hand_sprite.global_position = global_position
		arm_sprite.set_point_position(1, global_position)
	else:
		hand_sprite.global_position = grabbed_object.grab_marker.global_position
		arm_sprite.set_point_position(1, grabbed_object.global_position)
	hand_sprite.look_at(body.position)


func grab_handling():
	var grabbables = grab_area.get_overlapping_bodies()
	if Input.is_action_just_pressed("grab"):
		if grabbed_object == null:
			if grabbables.size() > 0:
				enter_grab(grabbables[0])
		else:
			exit_grab()
	if grabbed_object != null:
		var grab_velocity: Vector2 =  attach_static_body.global_position - grabbed_object.global_position
		grabbed_object.apply_force(grab_velocity * 100)
		#grabbed_object.linear_velocity = Vector2.ZERO
		#grabbed_object.rotation = rotation
		#global_position = grabbed_object.grab_marker.global_position
		
		#if grabbed_object.get_child(0).global_position.distance_to(attach_static_body.global_position) > 600:
			#exit_grab()
		pass
			
func enter_grab(new_object):
	grabbed_object = new_object
	#attach_static_body.set_collision_layer_value(1, true)
	
	attach_static_body.global_position = grabbed_object.global_position
	#grabbed_object.grab_marker.global_position = grab_area.global_position
	grabbed_object.linear_damp = 20
	#grabbed_object.angular_damp = 30
	set_collision_layer_value(1, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(2, false)
	grabbed_object.set_collision_layer_value(3, false)
	grabbed_object.set_collision_layer_value(4, true)
	grabbed_object.set_collision_mask_value(1, false)
	#object_initial_rotation = grabbed_object.rotation
	#create_pin_joint()

func exit_grab():
	global_position = grabbed_object.global_position
	grabbed_object.linear_damp = 0
	grabbed_object.angular_damp = 0

	set_collision_mask_value(2, true)
	
	attach_static_body.set_collision_layer_value(1, false)
	grabbed_object.set_collision_layer_value(3, true)
	grabbed_object.set_collision_layer_value(4, false)
	grabbed_object.set_collision_mask_value(1, true)
	grabbed_object = null
	
	await get_tree().create_timer(0.1).timeout
	set_collision_layer_value(1, true)
	set_collision_mask_value(3, true)
	#remove_pin_joint()

func create_spring():
	if spring == null:
		spring = DampedSpringJoint2D.new()
		attach_static_body.add_child(spring)
		spring.stiffness = 100
		spring.length = 1
		spring.damping = 1
		spring.bias = 0.9
	attach_static_body.global_position = grabbed_object.global_position
	grab_groove_joint.node_b = grabbed_object.get_path()
	spring.node_a = attach_static_body.get_path()
	spring.node_b = grabbed_object.get_path()

func remove_spring():
	spring.node_a = ""
	spring.node_b = ""

func create_pin_joint():
	if pin_joint == null:
		pin_joint = PinJoint2D.new()
		attach_static_body.add_child(pin_joint)
		#pin_joint.angular_limit_enabled = true
		#pin_joint.position = attach_static_body.position
	attach_static_body.global_position = grabbed_object.global_position
	pin_joint.bias = 0.5
	pin_joint.node_a = attach_static_body.get_path()
	pin_joint.node_b = grabbed_object.get_path()
	

func remove_pin_joint():
	pin_joint.node_a = ""
	pin_joint.node_b = ""
