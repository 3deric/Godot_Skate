class_name Trick
extends Node

var trick_name : String
var duration : float
var base_score : int
var difficulty : float
var base_state : CharacterStates.State
var input_sequence: Array[int]

func _init(): #prevent direct instancing of base class
	assert(false, "Trick is an abstract base class")

func matches_state(char_state : CharacterStates.State) -> bool:
	return base_state == char_state
	
func matches_input(buffer: Array[int]) -> bool:
	if buffer.size() < input_sequence.size():
		return false

	var start : int = buffer.size() - input_sequence.size()
	for i in input_sequence.size():
		if buffer[start + i] != input_sequence[i]:
			return false
	print(trick_name)
	return true

func calculate_score(combo_multiplier : int = 1) -> int:
	return int(base_score  * combo_multiplier)
