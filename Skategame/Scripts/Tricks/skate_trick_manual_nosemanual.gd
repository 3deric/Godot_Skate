class_name NoseManual
extends Trick

func _init():
	trick_name = "Nose Manual"
	base_states = [CharStates.State.GROUND, CharStates.State.PIPE]
	duration = 0.025
	base_score = 300
	difficulty = 1.0
	trick_animation = "Air_Olli"

	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.UP
		]
