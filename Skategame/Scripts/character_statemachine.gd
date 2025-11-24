extends Node3D

enum PlayerState {
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

@onready var character: CharacterBody3D = $".."

var player_state : PlayerState = PlayerState.RESET
var last_player_state : PlayerState = PlayerState.RESET


func set_player_state(new_state : PlayerState) -> void:
	player_state = new_state
	

func get_player_state() -> PlayerState:
	return player_state
	
	
func get_last_player_state() -> PlayerState:
	return last_player_state
	
	
func is_player_state(is_state : PlayerState) -> bool:
	return player_state == is_state
	

func is_last_player_state(is_state :PlayerState) -> bool:
	return last_player_state == is_state


func reset_player_state() -> void:
	player_state = PlayerState.RESET
	last_player_state = PlayerState.RESET
