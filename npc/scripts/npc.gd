class_name NPC extends RigidBody2D


@export var dialog_text: String = "You couldn't read the symbols..."
@onready var bubble_marker: Marker2D = $BubbleMarker

var is_dialog: bool = false

func create_dialog():
	if not is_dialog and not PlayerHud.speech_bubble.active:
		is_dialog = true
		PlayerHud.speech_bubble.show_dialog(dialog_text, bubble_marker)
	

func _process(delta: float) -> void:
	if is_dialog and PlayerHud.speech_bubble.active == false:
		is_dialog = false

# keep dialog open until the player walks away
# player can click again to advance dialog
