extends CharacterBody2D

@onready var body: Player = $".."


func _physics_process(delta: float) -> void:
	var hand_velocity: Vector2 = get_global_mouse_position() - global_position
	if hand_velocity.length() > 1800:
		hand_velocity = hand_velocity.normalized() * 1800
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
