class_name Backside
extends Trick

func _init():
	trick_name = "Backside Grind"
	base_states = [CharStates.State.GRIND]
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Grind_Backside"

	input_sequence = [
		CharacterInput.Action.DOWN,
		CharacterInput.Action.GRIND
		]
