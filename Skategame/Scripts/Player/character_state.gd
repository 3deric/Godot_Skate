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

func _handle_jump() -> void:
	if input.get_input_jump():
		ctrl.velocity += Vector3.UP * ctrl.stats.jump_vel
		input.set_jump_cooldown()
		transitioned.emit(self, "Player_Air")

func _grind_lip_check() -> void:
	if !input.get_input_grind():
		return
	if ctrl.path == null:
		return
	if ctrl.get_can_grind():
		transitioned.emit(self, "Player_Grind")
	elif ctrl.get_can_lip():
		transitioned.emit(self, "Player_Lip")
		
