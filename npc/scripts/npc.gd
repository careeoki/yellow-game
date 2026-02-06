class_name NPC extends RigidBody2D

const SPEECH_BUBBLE = preload("uid://d1wjg7kkmhtfi")

@export var dialog_text: String = "You couldn't read the symbols..."
@onready var bubble_marker: Marker2D = $BubbleMarker


func create_dialog():
	print("tired")
	var speech_bubble = SPEECH_BUBBLE.instantiate()
	add_child(speech_bubble)
	speech_bubble.global_position = bubble_marker.global_position
	speech_bubble.show_dialog(dialog_text)
	
