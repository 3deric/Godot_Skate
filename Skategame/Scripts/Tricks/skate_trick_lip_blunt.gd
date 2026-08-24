class_name Blunt
extends Trick

func _init():
	trick_name = "Blunt"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Lip_Blunt"

	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRIND
		]
