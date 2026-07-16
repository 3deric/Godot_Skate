class_name GameMenu
extends GameState

func enter():
	main_game.load_level(main_game.LEVEL_MENU_UID)
	# open menu scene
	# make main menu visible
	pass
	
func exit():
	# hide main menu
	pass
	
func update(_delta):
	pass
