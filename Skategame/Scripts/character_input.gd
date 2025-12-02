class_name CharacterInput
extends Node3D

@onready var Char_Controller: CharacterController = $".."

var input : Vector3i = Vector3.ZERO #input values
var input_tricks : Vector3i = Vector3.ZERO #input values for tricks


func _process(_delta):
	if !Char_Controller.is_playing:
		return
	_input_handler()
	
func _input_handler(): 	#handles player inputs
	input.x = int(Input.is_action_pressed('Left')) - int(Input.is_action_pressed('Right'))
	input.y = int(Input.is_action_pressed('Forward')) - int(Input.is_action_pressed('Backward'))
	input.z = int(Input.is_action_pressed('Jump'))
	input_tricks.x = int(Input.is_action_pressed('Grind'))
	input_tricks.y = int(Input.is_action_pressed('Revert'))
	input_tricks.z = int(Input.is_action_just_released('Jump'))
