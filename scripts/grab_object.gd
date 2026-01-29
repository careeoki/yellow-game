class_name Grab_Object extends RigidBody2D

var reset_state = false
var move_vector: Vector2

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset_state:
		state.transform = Transform2D(0.0, move_vector)
		reset_state = false

func move_body(target_pos: Vector2):
	move_vector = target_pos
	reset_state = true
