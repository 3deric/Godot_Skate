class_name Fiftyfifty
extends Trick

func _init():
	trick_name = "50-50"
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	allow_repeat = false
	input_sequence = [
		CharacterInput.Action.RIGHT,
		CharacterInput.Action.GRIND
		]
