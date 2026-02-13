class_name Boardslide
extends Trick

func _init():
	trick_name = "Boardslide"
	base_states = [CharStates.State.GRIND]
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Grind_Boardslide"

	input_sequence = [
		CharacterInput.Action.GRIND
		]
