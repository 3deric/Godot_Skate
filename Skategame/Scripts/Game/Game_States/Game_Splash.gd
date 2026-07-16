class_name GameSplash
extends GameState

@export var splash_time : float = 2.0
var _timer : float = 0.0

func enter():
	# load splash level
	# leave splash level after timeout
	pass
	
func exit():
	pass
	
func update(_delta):
	if _timer >= splash_time:
		transitioned.emit(self, "Game_Menu")
	_timer += _delta
