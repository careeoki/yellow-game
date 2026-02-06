extends Node2D
@onready var dialog: RichTextLabel = $Dialog

var typing_speed: float = 60
var typing_time: float

func show_dialog(text: String) -> void:
	dialog.text = text
	dialog.visible_characters = 0
	typing_time = 0
	while dialog.visible_characters < dialog.get_total_character_count():
		typing_time += get_process_delta_time()
		dialog.visible_characters = typing_speed * typing_time as int
		await get_tree().process_frame
