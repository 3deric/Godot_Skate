class_name Olli
extends Trick

func _init():
	trick_name = "Olli"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.025
	base_score = 300
	difficulty = 1.2

	input_sequence = [
		CharacterInput.Action.JUMP
		]
