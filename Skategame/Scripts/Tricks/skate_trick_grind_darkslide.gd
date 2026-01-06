class_name Darkslide
extends Trick

func _init():
	trick_name = "Darkslide"
	duration = 1.0
	base_score = 300
	difficulty = 1.0
	input_sequence = [
		CharacterInput.Action.LEFT,
		CharacterInput.Action.GRIND
		]
