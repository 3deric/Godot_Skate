class_name CharacterInput
extends Node3D

@onready var Char_Controller : CharacterController = $".."
@onready var Char_Init : CharacterInit = $"../.."

const JUMP_COOLDOWN : float = 1.0

var input : Vector3i = Vector3.ZERO #input values
var input_tricks : Vector3i = Vector3.ZERO #input values for tricks
var _jump_timer : float = 0.0


func _process(_delta):
	_jump_cooldown(_delta)
	_input_handler()
	
func _input_handler(): 	#handles player inputs
	input.x = int(Input.is_action_pressed('Left')) - int(Input.is_action_pressed('Right'))
	input.y = int(Input.is_action_pressed('Forward')) - int(Input.is_action_pressed('Backward'))
	input.z = int(Input.is_action_pressed('Jump'))
	input_tricks.x = int(Input.is_action_pressed('Grind'))
	input_tricks.y = int(Input.is_action_pressed('Revert'))
	input_tricks.z = int(Input.is_action_just_released('Jump'))

func _jump_cooldown(_delta) -> void:
	if _jump_timer > 0:
		_jump_timer -= _delta

func can_jump() -> bool:
	return _jump_timer < 0.01
		
func set_jump_cooldown() -> void:
	_jump_timer = JUMP_COOLDOWN
	
func get_input() -> Vector3i:
	return input
	
func get_input_tricks() -> Vector3i:
	return input_tricks
