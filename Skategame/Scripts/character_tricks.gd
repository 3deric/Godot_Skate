class_name CharacterTricks
extends Node3D

const COMBO_COOLDOWN_TIME : float = 0.5
const ROT_ROUNDING : float = 45

var available_grind_tricks: Array[Trick] = [
	Frontslide.new(),
	Tailslide.new(),
	Fiftyfifty.new(),
	Darkslide.new(),
	Boardslide.new()
	]
var available_grab_tricks : Array[Trick] = [
	Nosegrab.new(),
	Tailgrab.new(),
	Indygrab.new()
	]
var available_air_tricks : Array[Trick] = [
	Olli.new()
	]
var available_flip_tricks : Array[Trick] = [
	Heelflip.new(),
	Kickflip.new()
	]
var available_lip_tricks : Array[Trick] = [
	Axlestall.new(),
	Nosestall.new()
	]
var available_manual_tricks : Array[Trick] = []

var can_trick : bool = true
var current_trick : Trick = null
var tricks : Array[Trick] = []
var current_trick_duration : float = 0
var current_trick_rot : float = 0.0
var is_trick_active : bool = false
var combo_cooldown : float = 0.0


@onready var Char_Input : CharacterInput = $"../Char_Input"
@onready var Char : CharacterController = $".."
@onready var Ingame_Ui: IngameOverlay = $"../Ingame_Ui"
@onready var Char_Statemachine: CharacterStatemachine = $"../Char_Statemachine"
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_update_trick_ui()
	_trick_cooldown(delta)
	_combo_cooldown(delta)
	_set_trick_rot(delta * Char_Input.get_input_steering().x * Char.ROT_JUMP)
	if !can_trick:
		return
	if Char.get_can_grind() and Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRIND:
		Char_Statemachine.set_player_state(CharStates.State.GRIND)
		_start_trick(available_grind_tricks)
		return
	if Char.get_can_lip() and Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRIND:
		Char_Statemachine.set_player_state(CharStates.State.LIP)
		_start_trick(available_lip_tricks)
		return
	if Char.get_can_air():
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.JUMP:
			_start_trick(available_air_tricks)
			return
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.FLIP:
			_start_trick(available_flip_tricks)
			return
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRAB:
			_start_trick(available_grab_tricks)
			return
			
func _trick_cooldown(_delta) -> void:
	if current_trick_duration > 0.0:
		current_trick_duration -= _delta
		can_trick = false
	else:
		can_trick = true
		
func _combo_cooldown(_delta) -> void:
	pass
	
func _rot_round(rot : float) -> String:
	var _rounded : int = int(abs(ceil(rot / ROT_ROUNDING) * ROT_ROUNDING))
	if _rounded != 0:
		return str(_rounded)
	return ""
	
func _update_trick_ui():
	if !is_trick_active:
		return
	Ingame_Ui.set_trick_view(current_trick.trick_name + " " + _rot_round(rad_to_deg(current_trick.get_rotation())))
		
func _start_trick(_tricks : Array[Trick]):
	for trick in _tricks:
		if trick.matches_input(Char_Input.input_buffer.buffer):
			Char_Input.input_buffer.clear()
			current_trick = trick.get_script().new()
			is_trick_active = true
			current_trick_duration = current_trick.duration
			Ingame_Ui.set_trick_view(current_trick.trick_name)
			break
			
func _end_trick() -> void:
	is_trick_active = false
	current_trick = null
	can_trick = true
	
func get_can_trick() -> bool:
	return can_trick
#
func _set_trick_rot(_delta : float) -> void:
	if current_trick == null:
		return
	current_trick.set_rotation(_delta)

func set_state_changed() -> void:
	if is_trick_active:
		_end_trick()
		
func get_trick_duration() -> float:
	return current_trick_duration
