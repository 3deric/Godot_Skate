class_name GameState
extends Node

signal transitioned

var main_game : MainGame

func init(_main_game : MainGame) -> void:
	main_game = _main_game

func enter():
	pass
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	pass
