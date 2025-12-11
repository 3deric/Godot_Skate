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

const STATE_UPDATE_COOLDOWN_TIME : float = 0.05

var player_state : State = State.RESET
var last_player_state : State = State.RESET
var state_update_cooldown : float = 0.0


func _process(delta: float) -> void:
	_update_state_cooldown(delta)

func set_player_state(new_state : State) -> void:
	player_state = new_state
	_debug_player_state()
	_set_state_cooldown()
	
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

func get_can_change_state() -> bool:
	return state_update_cooldown < 0.01
	
func _set_state_cooldown():
	state_update_cooldown = STATE_UPDATE_COOLDOWN_TIME
	
func _update_state_cooldown(_delta : float):
	if state_update_cooldown >= 0:
		state_update_cooldown -= _delta
