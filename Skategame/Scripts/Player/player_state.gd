class_name PlayerState
extends Node

signal transitioned

var char_ctrl : CharacterController

func init(_char_ctrl : CharacterController) -> void:
	char_ctrl = _char_ctrl

func enter():
	pass
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	pass
