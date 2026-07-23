extends PlayerState

func enter():
	char_ctrl.can_air = true
	
func exit():
	char_ctrl.can_air = false

func physics_update(_delta : float):
	_pipe_snap_air_movement(_delta)
	_air_check()
	char_ctrl.set_previous_values()
	char_ctrl.set_char_up_direction()
	char_ctrl.global_transform = LibHelpers.align(char_ctrl.global_transform, char_ctrl.up_direction)
	char_ctrl.move_and_slide()

func _pipe_snap_air_movement(_delta) -> void:
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_jump * _delta)
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	
func _air_check() -> void:
	if !char_ctrl.Char_Input.get_input().y == 0:
		char_ctrl.reset_shapecast(true)
		transitioned.emit(self, "Player_Air")
