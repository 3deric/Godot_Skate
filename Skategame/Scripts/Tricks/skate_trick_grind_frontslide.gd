class_name Frontslide
extends Trick

func _init():
	trick_name = "Frontslide"
	base_states = [CharStates.State.GRIND]
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Lip"

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRIND
		]
