class_name Boardslide
extends Trick

func _init():
	trick_name = "Boardslide"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Grind_Boardslide"

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRIND
		]
