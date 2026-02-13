class_name Fiftyfifty
extends Trick

func _init():
	trick_name = "50-50 Grind"
	base_states = [CharStates.State.GRIND]
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Grind_5050"

	input_sequence = [
		CharacterInput.Action.RIGHT,
		CharacterInput.Action.GRIND
		]
