class_name CharacterInput
extends Node3D

@onready var Char_Controller : CharacterController = $".."
@onready var Player_Scene : Player = $"../.."
@onready var Char_Statemachine: CharacterStatemachine = $"../Char_Statemachine"
@onready var Ingame_Ui: IngameOverlay = $"../Ingame_Ui"

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

const JUMP_COOLDOWN : float = 0.1

var input_buffer : InputBuffer = InputBuffer.new()
var input : Vector3 = Vector3.ZERO #input values
var _jump_timer : float = 0.0

func _process(_delta):
	_update_input_buffer()
	#input_buffer.debug()
	_jump_cooldown(_delta)
	input_buffer.input_cooldown(_delta)
	_input_handler()
	_on_player_state_changed()
	
func _input_handler(): 	#handles player inputs
	input.x = Input.get_action_strength('Left') - Input.get_action_strength('Right')
	input.y = Input.get_action_strength('Up') - Input.get_action_strength('Down')
	input.z = int(Input.is_action_pressed('Jump'))

func _jump_cooldown(_delta) -> void:
	if _jump_timer > 0:
		_jump_timer -= _delta
		
func _update_input_buffer():
	if Input.is_action_just_released('Jump'):
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
		
	if input_buffer.get_buffer_cooldown() or input_buffer.get_buffer_updated():
		Ingame_Ui.update_input_buffer_vis(input_buffer.buffer)
			
func reset() -> void:
	input = Vector3i.ZERO
	input_buffer.clear()

func can_jump() -> bool:
	return _jump_timer < 0.01
		
func set_jump_cooldown() -> void:
	_jump_timer = JUMP_COOLDOWN
	
func get_input() -> Vector3:
	return input
	
func get_input_jump() -> bool:
	if input_buffer.get_last_input() == Action.JUMP and can_jump():
		input_buffer.buffer.clear()
		return true
	return false
	
func get_dir_before_jump() -> int:
	if input_buffer.get_second_last_input() == Action.LEFT:
		return 1
	if input_buffer.get_second_last_input() == Action.RIGHT:
		return -1
	else:
		return 0
			
func _on_player_state_changed():
	var current_state : CharStates.State = Char_Statemachine.player_state
	var last_state : CharStates.State = Char_Statemachine.last_player_state

	if current_state == CharStates.State.PIPESNAP and current_state != last_state and last_state != CharStates.State.RESET:
		var last_input = input_buffer.get_last_input()
		if not last_input == Action.JUMP:
			input_buffer.push(Action.JUMP)
