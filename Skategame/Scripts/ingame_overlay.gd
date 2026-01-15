class_name IngameOverlay
extends Control

const TRICK_LABEL_COOLDOWN_TIME : float = 2.0

var trick_label_cooldown : float = 0.0

@export var image_map: Dictionary = {
	0: preload("res://Assets/UI/Inputs/xbox/xbox_button_color_a.png"),
	1: preload("res://Assets/UI/Inputs/xbox/xbox_button_color_x.png"),
	2: preload("res://Assets/UI/Inputs/xbox/xbox_button_color_b.png"),
	3: preload("res://Assets/UI/Inputs/xbox/xbox_button_color_y.png"),
	4: preload("res://Assets/UI/Inputs/xbox/xbox_dpad_up.png"),
	5: preload("res://Assets/UI/Inputs/xbox/xbox_dpad_down.png"),
	6: preload("res://Assets/UI/Inputs/xbox/xbox_dpad_left.png"),
	7: preload("res://Assets/UI/Inputs/xbox/xbox_dpad_right.png"),
	8: preload("res://Assets/UI/Inputs/xbox/xbox_rb.png")
}

var input_images : Array[TextureRect] = []

@onready var Fail_View: Control = get_node('FailView')
@onready var Balance_View: Control = get_node('BalanceView')
@onready var Balance_Indicator: Control = get_node('BalanceView/BalanceIndicator')
@onready var Trick_Label : Label = $TrickView/TrickLabel
@onready var Input_Container : HBoxContainer = $TrickView/InputView

func _ready():
	set_fail_view(false)
	set_balance_value(false)
	_create_input_buffer_vis()
	
func _process(delta: float) -> void:
	_trick_label_view_cooldown(delta)
		
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
		
func _create_input_buffer_vis() -> void:
	for i in range(8):
		var tex_rect : TextureRect= TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		Input_Container.add_child(tex_rect)
		input_images.append(tex_rect)
	
func update_input_buffer_vis(_buffer : Array[int]) -> void:
	for i in range(input_images.size()):
		if i < _buffer.size():
			input_images[i].texture = image_map[_buffer[i]]
		else:
			input_images[i].texture = null
