class_name IngameOverlay
extends Control

const TRICK_LABEL_COOLDOWN_TIME : float = 2.0

var trick_label_cooldown : float = 0.0

@onready var Fail_View: Control = get_node('FailView')
@onready var Balance_View: Control = get_node('BalanceView')
@onready var Balance_Indicator: Control = get_node('BalanceView/BalanceIndicator')
@onready var Trick_Label : Label = $TrickView/TrickLabel

func _process(delta: float) -> void:
	_trick_label_view_cooldown(delta)

func _ready():
	set_fail_view(false)
	set_balance_value(false)
		
func set_fail_view(_val):
	#enable or disable fail view
	Fail_View.visible = _val
	
func set_balance_view(_val):
	#enable or disable balance view
	Balance_View.visible = _val
	
func set_balance_value(_val):
	#change angle of balance view
	_val = float(_val) / PI *400
	Balance_Indicator.position= Vector2(_val -2,-20)
	
func set_trick_view(_val):
	Trick_Label.text = _val
	trick_label_cooldown = TRICK_LABEL_COOLDOWN_TIME
	
func clear_trick_view():
	Trick_Label.text = ""

func _trick_label_view_cooldown(_delta):
	if trick_label_cooldown > 0.0:
		trick_label_cooldown -= _delta
	else:
		clear_trick_view()
