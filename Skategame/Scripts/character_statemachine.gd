class_name CharacterStatemachine
extends Node3D

const STATE_UPDATE_COOLDOWN_TIME : float = 0.05

@onready var Char_Tricks: CharacterTricks = $"../Char_Tricks"

var player_state : CharStates.State = CharStates.State.RESET
var last_player_state : CharStates.State = CharStates.State.RESET
var state_update_cooldown : float = 0.0


func _process(delta: float) -> void:
	_update_state_cooldown(delta)

func set_player_state(new_state : CharStates.State) -> void:
	if player_state != new_state:
		#_update_tricks(new_state)
		player_state = new_state
		_debug_player_state()
		_set_state_cooldown()
	
func set_last_player_state() -> void:
	_update_last_player_state()	

func get_player_state() -> CharStates.State:
	return player_state
	
	
func get_last_player_state() -> CharStates.State:
	return last_player_state
	
	
func is_player_state(is_state : CharStates.State) -> bool:
	return player_state == is_state
	

func is_last_player_state(is_state :CharStates.State) -> bool:
	return last_player_state == is_state


func reset_player_state() -> void:
	player_state = CharStates.State.RESET
	last_player_state = CharStates.State.RESET


func _update_last_player_state() -> void:
	last_player_state = player_state


func _debug_player_state() -> void:
	if(player_state != last_player_state):
		print(CharStates.State.find_key(player_state))

func get_can_change_state() -> bool:
	return state_update_cooldown < 0.01
	
func _set_state_cooldown():
	state_update_cooldown = STATE_UPDATE_COOLDOWN_TIME
	
func _update_state_cooldown(_delta : float):
	if state_update_cooldown >= 0:
		state_update_cooldown -= _delta

#func _update_tricks(new_state : CharStates.State):
	#if new_state == player_state:
		#return
	#if new_state == CharStates.State.GROUND or new_state == CharStates.State.PIPE or new_state == CharStates.State.FALL:
		#if new_state == CharStates.State.GROUND and player_state == CharStates.State.PIPE \
		#or new_state == CharStates.State.PIPE and player_state == CharStates.State.GROUND:
			#return
		#if player_state != CharStates.State.RESET:
			#Char_Tricks.set_end_trick(new_state)
#
	#else:
		#Char_Tricks.set_start_trick(new_state)
