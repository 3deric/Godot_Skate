class_name Indygrab
extends Trick

func _init():
	trick_name = "Indy Grab"
	duration = 0.15
	base_score = 300
	difficulty = 1.2
	trick_animation = "Grab_IndyGrab"
	can_rotate = true
	
	input_sequence = [
		CharacterInput.Action.GRAB
		]
