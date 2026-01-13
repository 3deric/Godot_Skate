class_name Boardslide
extends Trick

func _init():
	trick_name = "Boardslide"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	allow_repeat = false
	input_sequence = [
		CharacterInput.Action.GRIND
		]
