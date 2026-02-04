class_name EnemyStateHurt extends EnemyState

@export var anim_name: String = "hurt"

@export_category("AI") # oh... that's AI in my indieslop
@export var next_state: EnemyState

var _timer: float = 0.0
var _direction: Vector2
var _animation_finished: bool = false

func init() -> void:
	enemy.enemy_damaged.connect(_on_enemy_damaged)
	pass

func enter() -> void:
	var knockback_velocity
	enemy.invulnerable = true
	_direction = enemy.global_position.direction_to(enemy.last_hurt_box.global_position)
	_direction = enemy.global_position.direction_to(enemy.last_hurt_box.global_position)
	if enemy.last_hurt_box.dynamic_knockback:
		knockback_velocity = (enemy.last_hurt_box.get_parent().linear_velocity.length()) + 200
	else:
		knockback_velocity = enemy.last_hurt_box.knockback * 10
	enemy.set_direction(_direction)
	enemy.apply_impulse(_direction * -knockback_velocity)
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass

func exit() -> void:
	_animation_finished = false
	enemy.invulnerable = false
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

func process(_delta: float) -> EnemyState:
	if _animation_finished:
		return next_state
	return null

func physics(_delta: float) -> EnemyState:
	return null

func _on_enemy_damaged() -> void:
	state_machine.change_state(self)
	pass

func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
