class_name Manual
extends Trick

func _init():
	trick_name = "Manual"
	base_states = [CharStates.State.GROUND, CharStates.State.PIPE]
	duration = 0.025
	base_score = 300
	difficulty = 1.0
	trick_animation = "Air_Olli"

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.DOWN
		]
