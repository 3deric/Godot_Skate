class_name Kickflip
extends Trick

func _init():
	trick_name = "Kickflip"
	duration = 1.0
	base_score = 300
	difficulty = 1.2
	input_sequence = [
		CharacterInput.Action.FLIP
		]
