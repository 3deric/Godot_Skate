class_name Olli
extends Trick

func _init():
	trick_name = "Olli"
	duration = 0.025
	base_score = 300
	difficulty = 1.2
	trick_animation = "Air_Olli"
	can_rotate = true

	input_sequence = [
		CharacterInput.Action.JUMP
		]
