class_name Enemy extends RigidBody2D

signal direction_changed(new_direction)
signal enemy_damaged()
signal enemy_died()

const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

@export var max_health: int = 20

var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO
var player: Player
var invulnerable: bool = false

var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0

@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine

var health: int
var blood = preload("res://particles/blood.tscn")
var last_hurt_box: HurtBox = null

func _ready() -> void:
	health = max_health
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.Damaged.connect(_take_damage)

func set_direction(_new_direction: Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id: int = int(round(
		(direction * cardinal_direction * 0.1).angle()
		/ TAU * DIR_4.size()
	))
	var new_dir = DIR_4[direction_id]
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	return true


func _on_hit_box_damaged(_hurt_box: HurtBox) -> void:
	pass


func update_animation(state: String) -> void:
	animation_player.play(state)

func _take_damage(hurt_box: HurtBox) -> void:
	if hurt_box.get_parent() == self:
		return
	if invulnerable:
		return
	health -= hurt_box.damage
	last_hurt_box = hurt_box
	if health > 0:
		enemy_damaged.emit()
	else:
		enemy_died.emit()
	hurt_sound.pitch_scale = randf_range(0.9, 1.1)
	hurt_sound.play()
	create_blood()
	

func create_blood():
	var blood_instance = blood.instantiate()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
