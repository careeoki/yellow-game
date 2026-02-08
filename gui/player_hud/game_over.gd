extends MarginContainer


func _on_button_pressed() -> void:
	LevelManager.load_new_level("res://levels/test_0.tscn", "LevelTransition", Vector2(0, 256))
	PlayerManager.player.revive()
	hide()
