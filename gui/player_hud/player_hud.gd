extends CanvasLayer

@onready var health: RichTextLabel = $Health
@onready var game_over: MarginContainer = $GameOver
@onready var speech_bubble: SpeechBubble = $SpeechBubble

func _ready() -> void:
	PlayerManager.player.health_changed.connect(update_health)
	game_over.hide()

func update_health(_health: int) -> void:
	health.text = str(_health)
	if _health == 0:
		game_over.show()
