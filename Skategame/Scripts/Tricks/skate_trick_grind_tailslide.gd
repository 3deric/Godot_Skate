class_name Tailslide
extends Trick

func _init():
	trick_name = "Tailslide"
	duration = 1.0
	base_score = 300
	difficulty = 1.0
	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRIND
		]
