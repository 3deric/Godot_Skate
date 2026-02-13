class_name MelonGrab
extends Trick

func _init():
	trick_name = "Melon Grab"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	trick_animation = "Grab_MelonGrab"

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRAB
		]
