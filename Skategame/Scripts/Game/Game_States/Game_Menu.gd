class_name GameMenu
extends GameState

func init(main_game : MainGame) -> void:
	super(main_game)
	main_game.main_menu.button_start.button_down.connect(on_level1_pressed)
	main_game.main_menu.button_start_2.button_down.connect(on_level2_pressed)

func enter() -> void:
	main_game.load_level(main_game.selected_level_uid)
	main_game.main_menu.set_visibility(true)
	pass
	
func exit() -> void:
	main_game.main_menu.set_visibility(false)
	pass
	
func _start_level(_level : String):
	main_game.selected_level_uid = _level
	transitioned.emit(self, "Game_Level")

func on_level1_pressed():
	_start_level(main_game.LEVEL_1_UID)

func on_level2_pressed():
	_start_level(main_game.LEVEL_2_UID)
