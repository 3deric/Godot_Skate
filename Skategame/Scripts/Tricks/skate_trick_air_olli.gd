class_name Olli
extends Trick

func _init():
	trick_name = "Olli"
	duration = 0.05
	base_score = 300
	difficulty = 1.2
	is_air = true
	allow_repeat = false
	input_sequence = [
		CharacterInput.Action.JUMP
		]
