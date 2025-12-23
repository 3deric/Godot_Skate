class_name CharacterTricks
extends Node3D

const COMBO_COOLDOWN_TIME : float = 0.2
const ROT_ROUNDING : float = 45

var curr_trick_rot : float = 0.0
var curr_trick_time : float = 0.0
var curr_trick_state : CharStates.State = CharStates.State.RESET
var combo_cooldown : float = 0.0
var tricks : Dictionary = {}
var is_trick : bool = false

@onready var Char_Input : CharacterInput = $"../Char_Input"
@onready var Char : CharacterController = $".."
@onready var Ingame_Ui: IngameOverlay = $"../Ingame_Ui"
	
func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
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
		print("ending trick! with rot: " + str(abs(curr_trick_rot)))
		print("appending trick!")
		Ingame_Ui.set_trick_view(CharStates.state_to_string(curr_trick_state) + " " + _rot_round(curr_trick_rot))
	else:
		print("starting trick!")
	is_trick = true
	curr_trick_state = state
	
	
func set_end_trick(state : CharStates.State) -> void:
	if state == CharStates.State.FALL:
		_reset_trick_rot()
		print("failed trick!")
	else:
		Ingame_Ui.set_trick_view(CharStates.state_to_string(curr_trick_state) + " " + _rot_round(curr_trick_rot))
		print("ending trick! with rot: " + str(abs(curr_trick_rot)))
		_reset_trick_rot()
	is_trick = false
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
	return str(int(abs(ceil(rot / ROT_ROUNDING) * ROT_ROUNDING)))
