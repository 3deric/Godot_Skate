class_name CharacterStatemachine
extends Node3D

enum State {
	RESET, 
	GROUND, 
	PIPE, 
	PIPESNAP, 
	PIPESNAPAIR, 
	AIR, 
	FALL, 
	GRIND, 
	LIP, 
	MANUAL
	}


var player_state : State = State.RESET
var last_player_state : State = State.RESET


func set_player_state(new_state : State) -> void:
	player_state = new_state
	_debug_player_state()
	
func set_last_player_state() -> void:
	_update_last_player_state()	

func get_player_state() -> State:
	return player_state
	
	
func get_last_player_state() -> State:
	return last_player_state
	
	
func is_player_state(is_state : State) -> bool:
	return player_state == is_state
	

func is_last_player_state(is_state :State) -> bool:
	return last_player_state == is_state


func reset_player_state() -> void:
	player_state = State.RESET
	last_player_state = State.RESET


func _update_last_player_state() -> void:
	last_player_state = player_state


func _debug_player_state() -> void:
	if(player_state != last_player_state):
		print(State.find_key(player_state))
