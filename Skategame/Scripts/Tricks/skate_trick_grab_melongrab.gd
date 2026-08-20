class_name MelonGrab
extends Trick

func _init():
	trick_name = "Melon Grab"
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	trick_animation = "Grab_MelonGrab"
	can_rotate = true

	input_sequence = [
		CharacterInput.Action.UP,
		CharacterInput.Action.GRAB
		]
