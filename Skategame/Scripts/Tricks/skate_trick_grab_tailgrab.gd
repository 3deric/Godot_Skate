class_name Tailgrab
extends Trick

func _init():
	trick_name = "Tail Grab"
	duration = 1.0
	base_score = 300
	difficulty = 1.2
	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.FLIP
		]
