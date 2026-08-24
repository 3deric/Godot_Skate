class_name Trick
extends Node

var trick_name : String
var duration : float
var base_score : int
var difficulty : float
var base_state : CharacterStates.State
var input_sequence: Array[int]
var trick_rotation : float
var trick_animation : String
var can_rotate : bool = false

func _init(): #prevent direct instancing of base class
	assert(false, "Trick is an abstract base class")
		
func matches_input(buffer: Array[int]) -> bool:
	if buffer.size() < input_sequence.size():
		return false
	var start : int = buffer.size() - input_sequence.size()
	for i : int in input_sequence.size():
		if buffer[start + i] != input_sequence[i]:
			return false
	return true

func get_score() -> int:
	return int(base_score)
	
func set_rotation(_delta) -> void:
	trick_rotation += _delta
	
func get_rotation() -> float:
	if can_rotate:
		return trick_rotation
	return 0

func get_animation() -> String:
	return trick_animation
