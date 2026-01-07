class_name Tailgrab
extends Trick

func _init():
	trick_name = "Tail Grab"
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	is_air = true
	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRAB
		]
