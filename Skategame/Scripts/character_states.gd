class_name CharacterStates
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

func state_to_string(state : State) -> String:
	return State.find_key(state)
