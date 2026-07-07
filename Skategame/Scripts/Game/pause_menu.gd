class_name  PauseMenu
extends Control

@onready var button_continue: Button = %ButtonContinue
@onready var button_quit: Button = %ButtonQuit

func init() -> void:
	_setup_buttons()
	_set_menu(false)
	
func set_pause() -> void:
	if get_tree().paused == false:
		get_tree().paused = true
		_set_menu(true)
	else:
		get_tree().paused = false
		_set_menu(false)
	
func _setup_buttons() -> void:
	button_continue.button_down.connect(_on_button_continue_pressed)
	button_quit.button_down.connect(_on_button_quit_pressed)
	
func _set_menu(visibility : bool) -> void:
	self.visible = visibility

func _on_button_continue_pressed() -> void:
	set_pause()

func _on_button_quit_pressed() -> void:
	print("quit")
	
