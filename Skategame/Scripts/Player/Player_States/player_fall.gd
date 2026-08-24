extends CharacterState

func enter():
	ctrl.set_fall()
	
func exit():
	tricks.performed_olli = false
	ctrl.reset_shapecast(true)
	

func physics_update(_delta : float):
	if Input.is_action_pressed("Up"):
		transitioned.emit(self, "Player_Reset")
