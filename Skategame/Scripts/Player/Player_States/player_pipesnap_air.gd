extends CharacterState

func enter():
	pass
	
func exit():
	pass

func physics_update(_delta : float):
	_pipe_snap_air_movement(_delta)
	_air_check()
	ctrl.set_previous_values()
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	tricks.set_air_trick()
	_grind_lip_check()

func _pipe_snap_air_movement(_delta) -> void:
	ctrl.global_rotate(ctrl.xform.basis.y, ctrl.Char_Input.get_input().x * ctrl.stats.rot_jump * _delta)
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	
func _air_check() -> void:
	if !ctrl.Char_Input.get_input().y == 0:
		ctrl.reset_shapecast(true)
		transitioned.emit(self, "Player_Air")
