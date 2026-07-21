class_name GameLevel
extends GameState

func init(main_game : MainGame) -> void:
	super(main_game)
	main_game.pause_menu.button_quit.button_down.connect(_on_quit_pressed)
	main_game.pause_menu.button_continue.button_down.connect(_on_continue_pressed)

func enter() -> void:
	main_game.load_level(main_game.selected_level_uid)
	main_game.player.Char_Controller.char_states.set_force_state("Player_Reset")
	
func exit() -> void:
	pass
	
func update(_delta) -> void:
	if Input.is_action_just_released('Esc'):
		main_game.pause_menu.set_pause()

func _on_quit_pressed() -> void:
	main_game.pause_menu.set_pause()
	main_game.selected_level_uid = main_game.LEVEL_MENU_UID
	transitioned.emit(self, "Game_Menu")

func _on_continue_pressed() -> void:
	main_game.pause_menu.set_pause()
