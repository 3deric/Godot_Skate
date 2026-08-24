class_name Nosestall
extends Trick

func _init():
	trick_name = "Nosestall"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Lip_Nosestall"

	input_sequence = [
		CharacterInput.Action.GRIND
		]
