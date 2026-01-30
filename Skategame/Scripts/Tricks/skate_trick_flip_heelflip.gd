class_name Heelflip
extends Trick

func _init():
	trick_name = "Heelflip"
	base_states = [CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR]
	duration = 0.25
	base_score = 300
	difficulty = 1.2
	trick_animation = "Air"
	
	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.FLIP
		]
