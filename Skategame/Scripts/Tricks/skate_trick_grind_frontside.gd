class_name Frontside
extends Trick

func _init():
	trick_name = "Frontside Grind"
	base_states = [CharStates.State.GRIND]
	duration = 0.1
	base_score = 300
	difficulty = 1.0
	trick_animation = "Grind_Frontside"

	input_sequence = [
		CharacterInput.Action.GRIND
		]
