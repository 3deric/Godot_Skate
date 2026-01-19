class_name CharacterTurntable
extends Node3D

@onready var Char_Controller: CharacterController = $".."
@onready var Char_Input: CharacterInput = $"../Char_Input"
@onready var Player_Character: CharacterInit = $"../.."

const ROT : float= 2.0

func _physics_process(delta: float) -> void:
	if !Player_Character.get_is_playing():
		_rotate(delta)

func _rotate(_delta) -> void:
	Char_Controller.rotate_y(Char_Input.get_input().x * ROT * _delta)
