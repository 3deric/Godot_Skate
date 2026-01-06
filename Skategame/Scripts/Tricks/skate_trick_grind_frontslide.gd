class_name Frontslide
extends Trick

func _init():
	trick_name = "Frontslide"
	duration = 1.0
	base_score = 300
	difficulty = 1.0
	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRIND
		]
