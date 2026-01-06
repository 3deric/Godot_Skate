class_name Fiftyfifty
extends Trick

func _init():
	trick_name = "50-50"
	duration = 1.0
	base_score = 300
	difficulty = 1.0
	input_sequence = [
		CharacterInput.Action.RIGHT,
		CharacterInput.Action.GRIND
		]
