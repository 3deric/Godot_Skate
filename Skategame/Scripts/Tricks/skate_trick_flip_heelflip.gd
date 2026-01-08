class_name Heelflip
extends Trick

func _init():
	trick_name = "Heelflip"
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	is_air = true
	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.FLIP
		]
