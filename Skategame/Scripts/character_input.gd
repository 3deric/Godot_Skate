class_name CharacterInput
extends Node3D

@onready var Char_Controller : CharacterController = $".."
@onready var Char_Init : CharacterInit = $"../.."

enum Action {
	JUMP,
	FLIP,
	GRAB,
	GRIND,
	UP,
	DOWN,
	LEFT,
	RIGHT,
	REVERT
	}

const JUMP_COOLDOWN : float = 0.5

var input_buffer : InputBuffer = InputBuffer.new()
var input : Vector3i = Vector3i.ZERO #input values
var input_steering : Vector3 = Vector3.ZERO #input values
var input_tricks : Vector3i = Vector3i.ZERO #input values for tricks
var _jump_timer : float = 0.0
var _input_timer : float = 0.0

func _process(_delta):
	_update_input_buffer()
	#input_buffer.debug()
	_jump_cooldown(_delta)
	input_buffer.input_cooldown(_delta)
	_input_handler()
	
func _input_handler(): 	#handles player inputs
	input.x = int(Input.is_action_pressed('Left')) - int(Input.is_action_pressed('Right'))
	input.y = int(Input.is_action_pressed('Up')) - int(Input.is_action_pressed('Down'))
	input.z = int(Input.is_action_pressed('Jump'))
	#input_tricks.x = int(Input.is_action_pressed('Grind'))
	input_tricks.z = int(Input.is_action_just_released('Jump'))
	input_steering.x = int(Input.is_action_pressed('Steer_Left')) - int(Input.is_action_pressed('Steer_Right'))
	input_steering.y = int(Input.is_action_pressed('Steer_Up')) - int(Input.is_action_pressed('Steer_Down'))

func _jump_cooldown(_delta) -> void:
	if _jump_timer > 0:
		_jump_timer -= _delta
		
func _update_input_buffer():
	if Input.is_action_just_pressed("Jump") or int(Input.is_action_just_released('Jump')):
		input_buffer.push(Action.JUMP)

	if Input.is_action_just_pressed("Grind"):
		input_buffer.push(Action.GRIND)
		
	if Input.is_action_just_pressed("Grab"):
		input_buffer.push(Action.GRAB)
		
	if Input.is_action_just_pressed("Flip"):
		input_buffer.push(Action.FLIP)

	if Input.is_action_just_pressed("Up"):
		input_buffer.push(Action.UP)

	if Input.is_action_just_pressed("Down"):
		input_buffer.push(Action.DOWN)
				
	if Input.is_action_just_pressed("Left"):
		input_buffer.push(Action.LEFT)
				
	if Input.is_action_just_pressed("Right"):
		input_buffer.push(Action.RIGHT)
	
	if Input.is_action_just_pressed('Revert'):
		input_buffer.push(Action.REVERT)
		
func reset() -> void:
	input = Vector3i.ZERO
	input_tricks = Vector3i.ZERO
	input_buffer.clear()

func can_jump() -> bool:
	return _jump_timer < 0.01
		
func set_jump_cooldown() -> void:
	_jump_timer = JUMP_COOLDOWN
	
func get_input() -> Vector3i:
	return input
	
func get_input_tricks() -> Vector3i:
	return input_tricks
	
func get_input_steering() -> Vector3:
	return input_steering
	
