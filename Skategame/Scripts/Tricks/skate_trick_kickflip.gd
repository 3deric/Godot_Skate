class_name Kickflip
extends Trick

func _init():
	trick_name = "Kickflip"
	base_score = 300
	difficulty = 1.2
	input_sequence = [
		CharacterInput.Action.UP, 
		CharacterInput.Action.FLIP
		]
