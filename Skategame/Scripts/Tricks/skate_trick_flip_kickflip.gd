class_name Kickflip
extends Trick

func _init():
	trick_name = "Kickflip"
	duration = 0.25
	base_score = 300
	difficulty = 1.2
	is_air = true
	allow_repeat = true
	input_sequence = [
		CharacterInput.Action.FLIP
		]
