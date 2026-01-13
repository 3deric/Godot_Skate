class_name Tailslide
extends Trick

func _init():
	trick_name = "Tailslide"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	allow_repeat = false
	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRIND
		]
