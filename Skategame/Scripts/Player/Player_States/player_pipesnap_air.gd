extends PlayerState

func enter():
	char_ctrl.can_air = true
	
func exit():
	char_ctrl.can_air = false

func physics_update(_delta : float):
	_pipe_snap_air_movement(_delta)

func _pipe_snap_air_movement(_delta) -> void:
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_jump * _delta)
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
