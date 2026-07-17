class_name GameLevel
extends GameState

func enter():
	main_game.load_level(main_game.LEVEL_1_UID)
	# place player at level spawn
	pass
	
func exit():
	pass
	
func update(_delta):
	# check for pause input
	pass
