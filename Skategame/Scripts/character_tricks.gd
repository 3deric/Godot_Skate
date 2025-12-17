class_name CharacterTricks
extends Node3D

var curr_trick_rot : float = 0.0
var curr_trick_time : float = 0.0
var tricks : Dictionary = {}
var is_trick : bool = false
	
func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	pass
		
		
func set_start_trick(state : CharStates.State) -> void:
	if is_trick:
		print("appending trick!")
	else:
		print("starting trick!")
	is_trick = true
	
	
func set_end_trick(state : CharStates.State) -> void:
	if state == CharStates.State.FALL:
		print("failed trick!")
	else:
		print("ending trick!")
	is_trick = false
		
func _set_append_trick(state : CharStates.State) -> void:
	pass

func set_trick_rot(_delta : float) -> void:
	curr_trick_rot += _delta
	
func _reset_trick_rot() -> void:
	curr_trick_rot = 0.0
	
func end_combo() -> void:
	tricks = {}
