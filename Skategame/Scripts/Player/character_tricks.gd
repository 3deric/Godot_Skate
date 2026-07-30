class_name CharacterTricks
extends Node3D

const COMBO_COOLDOWN_TIME : float = 0.5
const ROT_ROUNDING : float = 15

var available_grind_tricks: Array[Trick] = [
	Backside.new(),
	Fiftyfifty.new(),
	Boardslide.new(),
	Frontside.new(),
	]
var available_grab_tricks : Array[Trick] = [
	MelonGrab.new(),
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
	Blunt.new(),
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
@onready var Char_Animation : CharacterAnimation = $"../Char_Animation"
	
func _ready() -> void:
	available_air_tricks = order_tricks_by_desc_complexity(available_air_tricks)
	available_lip_tricks = order_tricks_by_desc_complexity(available_lip_tricks)
	available_grab_tricks = order_tricks_by_desc_complexity(available_grab_tricks)
	available_grind_tricks = order_tricks_by_desc_complexity(available_grind_tricks)
	
func _process(delta: float) -> void:
	_update_trick_ui()
	_trick_cooldown(delta)
	_set_trick_rot(delta * Char_Input.get_input().x * Char.stats.rot_jump)

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
		
func _start_trick(_tricks : Array[Trick]) -> void:
	for trick : Trick in _tricks:
		if trick.matches_input(Char_Input.input_buffer.buffer) or trick.trick_name == 'Olli':
			if _get_trick_active():
				_end_trick()
			Char_Input.input_buffer.clear()
			current_trick = trick.get_script().new()
			_set_trick_active(true)
			current_trick_duration = current_trick.duration
			Ingame_Ui.set_trick_view(current_trick.trick_name)
			combo_cooldown = COMBO_COOLDOWN_TIME
			Char_Animation.set_trick_animation(trick.get_animation())
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
	if is_trick_active:
		_end_trick()
		
func get_trick_active() -> bool:
	return is_trick_active
		
func get_trick_duration() -> float:
	return current_trick_duration

func get_last_trick() -> Trick:
	var _size : int = tricks.size()
	if _size > 0:
		return tricks[_size -1]
	return null

func set_end_combo() -> void:
	var _combo_text : String = ""
	for trick : Trick in tricks:
		if trick == null:
			break
		_combo_text += " " + trick.trick_name + " " + str(_rot_round(rad_to_deg(trick.get_rotation())))
		print(" - " + trick.trick_name)
	_combo_text +=  " X" +str(tricks.size())
	Ingame_Ui.set_trick_view(_combo_text)
	tricks.clear()
	
func _set_trick_active(active : bool) -> void:
	is_trick_active = active
	
func _get_trick_active() -> bool:
	return is_trick_active
	
func set_clear_tricks() -> void:
	_end_trick()
	tricks.clear()
	current_trick = null

func order_tricks_by_desc_complexity(_tricks : Array[Trick]) -> Array[Trick]:
	var _sorted_tricks = _tricks.duplicate()
	_sorted_tricks.sort_custom(func(a, b): return a.input_sequence.size() > b.input_sequence.size())
	return _sorted_tricks
	
func set_combo_cooldown(_delta : float):
	_combo_cooldown(_delta)
	
func set_start_grind():
	_start_trick(available_grind_tricks)	

func set_start_lip():
	_start_trick(available_grind_tricks)	

func set_start_air():
	_start_trick(available_air_tricks)
		
func set_air_trick():
	if !can_trick:
		return
	if Char_Input.input_buffer.get_last_input() == Char_Input.Action.FLIP:
		_start_trick(available_flip_tricks)
		return
	if Char_Input.input_buffer.get_last_input() == Char_Input.Action.GRAB:
		_start_trick(available_grab_tricks)
		return
			
func set_end_air():
	_end_trick()
