class_name Boardslide
extends Trick

func _init():
	trick_name = "Boardslide"
	duration = 1.0
	base_score = 300
	difficulty = 1.0
	input_sequence = [
		CharacterInput.Action.GRIND
		]
