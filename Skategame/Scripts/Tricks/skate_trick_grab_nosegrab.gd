class_name Nosegrab
extends Trick

func _init():
	trick_name = "Nose Grab"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	trick_animation = "AirRight"

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRAB
		]
