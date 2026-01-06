class_name Nosegrab
extends Trick

func _init():
	trick_name = "Nose Grab"
	duration = 1.0
	base_score = 300
	difficulty = 1.2
	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.FLIP
		]
