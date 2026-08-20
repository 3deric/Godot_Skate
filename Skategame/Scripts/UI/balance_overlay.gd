class_name BalanceOverlay
extends Control

static var instance: BalanceOverlay

@onready var Balance_View: Control = self
@onready var Balance_Indicator: Control = get_node('BalanceViewIndicator')

func _ready():
	instance = self
	set_balance_view(false)
	
func set_balance_view(_val : bool, _rot : float = 0.0):
	#enable or disable balance view
	Balance_View.visible = _val
	Balance_View.rotation = _rot
	
func set_balance_value(_val : float):
	#change angle of balance view
	Balance_Indicator.rotation = -_val
