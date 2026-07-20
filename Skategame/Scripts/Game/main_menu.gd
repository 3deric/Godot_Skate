class_name  MainMenu
extends Control


@onready var panel_main: Panel = %PanelMain
@onready var panel_customization: Panel = %PanelCustomization
@onready var panel_options: Panel = %PanelOptions
@onready var button_start: Button = %ButtonStart
@onready var button_start_2: Button = %ButtonStart2
@onready var button_options: Button = %ButtonOptions
@onready var button_customization: Button = %ButtonCustomization
@onready var button_back_options: Button = %ButtonBackOptions
@onready var button_back_customization: Button = %ButtonBackCustomization

var main_game : MainGame = null

func init(main : MainGame) -> void:
	_setup_buttons()
	set_visibility(false)

func set_visibility(_vis : bool):
	self.visible = _vis

func _setup_buttons() -> void:
	#button_start.button_down.connect()
	#button_start_2.button_down.connect()
	button_options.button_down.connect(_on_button_options_pressed)
	button_customization.button_down.connect(_on_button_customization_pressed)
	button_back_options.button_down.connect(_on_button_back_options_pressed)
	button_back_customization.button_down.connect(_on_button_back_customization_pressed)

#func _on_button_start_pressed() -> void:
	#pass
	#
#func _on_button_start_2_pressed() -> void:
	#pass

func _on_button_options_pressed() -> void:
	panel_main.visible = false
	panel_customization.visible = false
	panel_options.visible = true


func _on_button_customization_pressed() -> void:
	panel_main.visible = false
	panel_customization.visible = true
	panel_options.visible = false


func _on_button_back_customization_pressed() -> void:
	panel_main.visible = true
	panel_customization.visible = false
	panel_options.visible = false


func _on_button_back_options_pressed() -> void:
	panel_main.visible = true
	panel_customization.visible = false
	panel_options.visible = false
