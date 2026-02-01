extends AnimatedSprite2D
@onready var hand: PlayerHand = $"../Hand"


func _physics_process(delta: float) -> void:
	#ik tgis sucks 
	if hand.grab_area.get_overlapping_bodies().size() > 0 and hand.grabbed_object == null:
		animation = "reach"
	elif hand.grabbed_object != null:
		animation = "grab"
	else:
		animation = "idle"
