class_name Tailgrab
extends Trick

func _init():
	trick_name = "Tail Grab"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.15
	base_score = 300
	difficulty = 1.2

	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRAB
		]
