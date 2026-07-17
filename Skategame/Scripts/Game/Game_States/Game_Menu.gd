class_name GameMenu
extends GameState

func enter():
	main_game.load_level(main_game.selected_level_uid)
	main_game.main_menu.set_visibility(true)
	pass
	
func exit():
	# hide main menu
	pass
	
func _start_level(_level : String):
	main_game.selected_level_uid = _level
	transitioned.emit(self, "Game_Level")

func _on_level1_pressed():
	_start_level(main_game.LEVEL_1_UID)

func _on_level2_pressed():
	_start_level(main_game.LEVEL_2_UID)
