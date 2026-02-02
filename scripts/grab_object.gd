class_name GrabObject extends RigidBody2D

@export var equipable: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var hit_sound_velocity = 900
var reset_state = false
var move_vector: Vector2
var target_position = null
var default_turn_speed = 20
var equip_position = null

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if target_position:
		SmoothLookAtRigid(target_position, default_turn_speed)
	if equip_position:
		global_position = equip_position.global_position
		rotation = 0
	pass

# via https://github.com/LillyByte/godot-smoothlookat2d
func SmoothLookAtRigid(target_pos, turn_speed):
	var target = target_pos.angle_to_point(global_position)
	angular_velocity = clamp((fposmod(target - rotation + PI, TAU ) - PI) * turn_speed, -40, 40)
	

func exit_grab():
	target_position = null

func equip(attach_point):
	
	rotation = 0
	equip_position = attach_point
	set_collision_layer_value(4, false)


func _on_body_entered(body: Node) -> void:
	if abs(linear_velocity.x) > hit_sound_velocity or abs(linear_velocity.y) > hit_sound_velocity:
		hit_sound.pitch_scale = randf_range(0.9, 1.1)
		hit_sound.play()
