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
var available_flip_tricks : Array[Trick] = [
	Kickflip.new()
]
var available_lip_tricks : Array[Trick] = []
var available_manual_tricks : Array[Trick] = []
	
var current_trick : Trick = null

var curr_trick_rot : float = 0.0
var curr_trick_time : float = 0.0
var curr_trick_state : CharStates.State = CharStates.State.RESET
var combo_cooldown : float = 0.0
var tricks : Dictionary = {}
var is_trick : bool = false

@onready var Char_Input : CharacterInput = $"../Char_Input"
@onready var Char : CharacterController = $".."
@onready var Ingame_Ui: IngameOverlay = $"../Ingame_Ui"
@onready var Char_Statemachine: CharacterStatemachine = $"../Char_Statemachine"
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:	
	_update_trick_ui()
	if Char.get_can_grind() and Char_Input.input_buffer.get_last_input() == 3:
		for trick in available_grind_tricks:
			if trick.matches_input(Char_Input.input_buffer.buffer):
				Char_Statemachine.set_player_state(CharStates.State.GRIND)
				Char_Input.input_buffer.clear()
				current_trick = trick
				break
	if Char.get_can_lip() and Char_Input.input_buffer.get_last_input() == 3:
		Char_Statemachine.set_player_state(CharStates.State.LIP)
	if combo_cooldown > 0.0:
		combo_cooldown -= delta
	if !is_trick:
		return
	if curr_trick_state == CharStates.State.AIR or\
		curr_trick_state == CharStates.State.PIPESNAP or\
		curr_trick_state == CharStates.State.PIPESNAPAIR:
		curr_trick_rot += Char_Input.get_input().x * Char.ROT_JUMP
			
func set_start_trick(state : CharStates.State) -> void:
	if is_trick or combo_cooldown > 0.01:
		_set_append_trick(state)
		#print("ending trick! with rot: " + str(abs(curr_trick_rot)))
		#print("appending trick!")			
	else:
		pass
		#print("starting trick!")
	is_trick = true
	curr_trick_state = state
	
func set_end_trick(state : CharStates.State) -> void:
	if state == CharStates.State.FALL:
		_reset_trick_rot()
		print("failed trick!")
	else:
		print("ending trick! with rot: " + str(abs(curr_trick_rot)))
		_reset_trick_rot()
	is_trick = false
	current_trick = null
	curr_trick_state = CharStates.State.RESET
	combo_cooldown = COMBO_COOLDOWN_TIME
		
func _set_append_trick(state : CharStates.State) -> void:
	curr_trick_rot = 0

func set_trick_rot(_delta : float) -> void:
	curr_trick_rot += _delta
	
func _reset_trick_rot() -> void:
	curr_trick_rot = 0.0
	
func end_combo() -> void:
	tricks = {}
	
func _rot_round(rot : float) -> String:
	var _rounded : int = int(abs(ceil(rot / ROT_ROUNDING) * ROT_ROUNDING))
	if _rounded != 0:
		return str(_rounded)
	return ""
	
func _update_trick_ui():
	#if curr_trick_state == CharStates.State.FALL:
		#return
	#if curr_trick_state == CharStates.State.RESET:
		#return
	if current_trick != null:
		Ingame_Ui.set_trick_view(current_trick.trick_name + " " + _rot_round(curr_trick_rot))
