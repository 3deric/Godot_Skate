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
var current_air_rot : float = 0.0
var is_trick_active : bool = false
var combo_cooldown : float = 0.0
var performed_olli : bool = false

@onready var Char_Input : CharacterInput = $"../Char_Input"
@onready var Char : CharacterController = $".."
@onready var Ingame_Ui: IngameOverlay = $"../Ingame_Ui"
@onready var Char_Statemachine: CharacterStatemachine = $"../Char_Statemachine"
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_update_trick_ui()
	_trick_cooldown(delta)
	_set_trick_rot(delta * Char_Input.get_input().x * Char.ROT_JUMP)
	if Char_Statemachine.is_player_state(CharStates.State.GROUND) or Char_Statemachine.is_player_state(CharStates.State.PIPE):
		_combo_cooldown(delta)
		performed_olli = false
	if !can_trick:
		return
	if Char.get_can_grind() and Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRIND:
		Char_Statemachine.set_player_state(CharStates.State.GRIND)
		_start_trick(available_grind_tricks)	
		Char.is_jump = false
		performed_olli = false
		return
	if Char.get_can_lip() and Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRIND:
		Char_Statemachine.set_player_state(CharStates.State.LIP)
		Char.is_jump = false
		_start_trick(available_lip_tricks)
		performed_olli = false
		return
	if Char.get_can_air():
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.JUMP:
			if performed_olli:
				return
			_start_trick(available_air_tricks)
			performed_olli = true
			return
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.FLIP:
			_start_trick(available_flip_tricks)
			performed_olli = true
			return
		if Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRAB:
			_start_trick(available_grab_tricks)
			performed_olli = true
			return
			
func _trick_cooldown(_delta) -> void:
	if current_trick_duration > 0.0:
		current_trick_duration -= _delta
		can_trick = false
	else:
		can_trick = true
		
func _combo_cooldown(_delta) -> void:
	if combo_cooldown > 0.0:
		combo_cooldown -= _delta
	elif tricks.size() > 0:
		set_end_combo()
	
func _rot_round(rot : float) -> String:
	var _rounded : int = int(abs(round(rot / ROT_ROUNDING) * ROT_ROUNDING))
	if _rounded != 0:
		return str(_rounded)
	return ""
	
func _update_trick_ui():
	if !_get_trick_active():
		return
	Ingame_Ui.set_trick_view(current_trick.trick_name + " " + _rot_round(rad_to_deg(current_trick.get_rotation())))
		
func _start_trick(_tricks : Array[Trick]):
	for trick in _tricks:
		if trick.matches_input(Char_Input.input_buffer.buffer):
			if _get_trick_active():
				_end_trick()
			Char_Input.input_buffer.clear()
			current_trick = trick.get_script().new()
			_set_trick_active(true)
			current_trick_duration = current_trick.duration
			Ingame_Ui.set_trick_view(current_trick.trick_name)
			combo_cooldown = COMBO_COOLDOWN_TIME
			break
			
func _end_trick() -> void:
	tricks.push_back(current_trick)
	_set_trick_active(false)
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
	if Char_Statemachine.get_player_state() == CharStates.State.FALL:
		return
	if is_trick_active:
		if !can_trick:
			Char.trick_not_finished = true
		_end_trick()
		
func get_trick_duration() -> float:
	return current_trick_duration

func get_last_trick() -> Trick:
	var _size : int = tricks.size()
	if _size > 0:
		return tricks[_size -1]
	return null

func set_end_combo():
	var _combo_text : String = ""
	for trick in tricks:
		if trick == null:
			break
		_combo_text += " " + trick.trick_name + " " + str(_rot_round(rad_to_deg(trick.get_rotation())))
		print(" - " + trick.trick_name)
	_combo_text +=  " X" +str(tricks.size())
	Ingame_Ui.set_trick_view(_combo_text)
	tricks.clear()
	
func _set_trick_active(active : bool):
	is_trick_active = active
	
func _get_trick_active() -> bool:
	return is_trick_active
	
func set_clear_tricks():
	_end_trick()
	tricks.clear()
	current_trick = null
