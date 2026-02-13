class_name Indygrab
extends Trick

func _init():
	trick_name = "Indy Grab"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	trick_animation = "Grab_IndyGrab"

	input_sequence = [
		CharacterInput.Action.GRAB
		]
