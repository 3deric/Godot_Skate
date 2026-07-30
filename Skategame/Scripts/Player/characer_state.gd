class_name CharacterState
extends Node

signal transitioned

var ctrl : 	 CharacterController
var anim : 	 CharacterAnimation
var input :  CharacterInput
var state :  CharacterStatemachine
var tricks : CharacterTricks

func init(_ctrl : CharacterController, _statemachine : CharacterStatemachine, _input : CharacterInput, _anim : CharacterAnimation, _tricks : CharacterTricks) -> void:
	ctrl 	= _ctrl
	state 	= _statemachine
	input 	= _input
	anim 	= _anim
	tricks 	= _tricks
	
func enter():
	pass
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	pass
