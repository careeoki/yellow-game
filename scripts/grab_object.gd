class_name Grab_Object extends RigidBody2D
@onready var grab_marker: Marker2D = $GrabMarker

var reset_state = false
var move_vector: Vector2
var target_position = null
var default_turn_speed = 20

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if target_position:
		SmoothLookAtRigid(target_position, default_turn_speed)
	pass

# via https://github.com/LillyByte/godot-smoothlookat2d
func SmoothLookAtRigid(target_pos, turn_speed):
	var target = target_pos.angle_to_point(global_position)
	angular_velocity = (fposmod(target - rotation + PI, TAU ) - PI) * turn_speed

func exit_grab():
	target_position = null
