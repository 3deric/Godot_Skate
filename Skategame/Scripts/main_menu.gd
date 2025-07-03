extends Control


@onready var panel_main: Panel = $"../MarginContainer/Container/PanelMain"
@onready var panel_customization: Panel = $"../MarginContainer/Container/PanelCustomization"
@onready var panel_options: Panel = $"../MarginContainer/Container/PanelOptions"
@onready var button_start: Button = $"../MarginContainer/Container/PanelMain/MarginContainer/VBoxContainer/ButtonStart"
@onready var button_options: Button = $"../MarginContainer/Container/PanelMain/MarginContainer/VBoxContainer/ButtonOptions"
@onready var button_customization: Button = $"../MarginContainer/Container/PanelMain/MarginContainer/VBoxContainer/ButtonCustomization"
@onready var button_back_options: Button = $"../MarginContainer/Container/PanelOptions/VBoxContainer/ButtonBackOptions"
@onready var button_back_customization: Button = $"../MarginContainer/Container/PanelCustomization/VBoxContainer/ButtonBackCustomization"

func _ready() -> void:
	_setup_buttons()


func _setup_buttons() -> void:
	button_start.button_down.connect(_on_button_start_pressed)
	button_options.button_down.connect(_on_button_options_pressed)
	button_customization.button_down.connect(_on_button_customization_pressed)
	button_back_options.button_down.connect(_on_button_back_options_pressed)
	button_back_customization.button_down.connect(_on_button_back_customization_pressed)

func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/test_level.tscn")


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
