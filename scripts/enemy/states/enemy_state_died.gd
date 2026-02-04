class_name EnemyStateDied extends EnemyState

@export var anim_name: String = "dead"

@export_category("AI") # oh... that's AI in my indieslop

var _direction: Vector2
var _animation_finished: bool = false

func init() -> void:
	enemy.enemy_died.connect(_on_enemy_died)
	pass

func enter() -> void:
	var knockback_velocity
	enemy.invulnerable = true
	_direction = enemy.global_position.direction_to(enemy.last_hurt_box.global_position)
	if enemy.last_hurt_box.dynamic_knockback:
		knockback_velocity = (enemy.last_hurt_box.get_parent().linear_velocity.length()) + 200
	else:
		knockback_velocity = enemy.last_hurt_box.knockback
	enemy.set_direction(_direction)
	enemy.apply_impulse(_direction * -knockback_velocity)
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass

func exit() -> void:
	enemy.invulnerable = false
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

func process(_delta: float) -> EnemyState:
	return null

func physics(_delta: float) -> EnemyState:
	return null

func _on_enemy_died() -> void:
	state_machine.change_state(self)
	pass

func _on_animation_finished(_a: String) -> void:
	enemy.queue_free()
