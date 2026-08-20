class_name Kickflip
extends Trick

func _init():
	trick_name = "Kickflip"
	duration = 0.5
	base_score = 300
	difficulty = 1.2
	trick_animation = "Flip_Kickflip"
	can_rotate = true

	input_sequence = [
		CharacterInput.Action.FLIP
		]
