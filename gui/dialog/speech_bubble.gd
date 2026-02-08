class_name SpeechBubble extends Control

signal letter_added(letter: String)
signal finished_typing


var target: Marker2D = null

var active: bool = false
var text_in_progress: bool = false

var text_speed: float = 0.03
var text_length: int = 0
var plain_text: String

@onready var dialog: RichTextLabel = $MarginContainer/TextMargins/Dialog
@onready var margin_container: MarginContainer = $MarginContainer
@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var tail_sprite: Sprite2D = $TailSprite

func _ready() -> void:
	hide()
	timer.timeout.connect(_on_timer_timeout)
	letter_added.connect(_new_letter_added)
	finished_typing.connect(exit_dialog)

func show_dialog(text: String, marker: Marker2D) -> void:
	active = true
	show()
	move_to_position(marker)
	
	dialog.text = text
	
	dialog.visible_characters = 0
	text_length = dialog.get_total_character_count()
	plain_text = dialog.get_parsed_text()
	text_in_progress = true
	start_timer(text_speed)
	
	pop_in()

func exit_dialog():
		await get_tree().create_timer(2).timeout
		await pop_out()
		hide()
		target = null
		active = false

func move_to_position(marker: Marker2D):
	global_position = marker.get_global_transform_with_canvas().origin
	target = marker

func _physics_process(_delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.get_global_transform_with_canvas().origin, 0.3)
		

func start_timer(speed: float) -> void:
	timer.wait_time = speed
	timer.start()
	pass

func _on_timer_timeout() -> void:
	dialog.visible_characters += 1
	if dialog.visible_characters <= text_length:
		letter_added.emit(plain_text[dialog.visible_characters - 1])
	else:
		text_in_progress = false
		finished_typing.emit()
	pass

func _new_letter_added(l: String) -> void:
	if not ' !?,.:;"'.contains(l):
		audio_stream_player.play()
	if not '!?,.:;"'.contains(l):
		start_timer(text_speed)
	else:
		start_timer(0.06)
	

func pop_in():
	var tween = create_tween()
	scale = Vector2.ZERO
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	await tween.finished
	return true

func pop_out():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	await tween.finished
	return true
