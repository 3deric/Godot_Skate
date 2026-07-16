class_name GameSplash
extends GameState

@export var splash_time : float = 2.0
var _timer : float = 0.0

func enter():
	main_game.init_player()
	main_game.load_level(main_game.LEVEL_SPLASH_UID)
	_set_timer()
	
func exit():
	pass
	
func update(_delta) -> void:
	if _timer >= splash_time:
		transitioned.emit(self, "Game_Menu")
	_timer += _delta

func _set_timer() -> void:
	_timer = 0.0
