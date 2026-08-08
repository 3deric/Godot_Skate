extends CharacterState

func enter():
	pass
	
func exit():
	pass

func physics_update(_delta : float):
	_pipe_snap_air_movement(_delta)
	if _air_check():
		return
	if _fall_check():
		return
	if _grind_lip_check():
		return
	tricks.set_air_trick()

func _pipe_snap_air_movement(_delta) -> void:
	ctrl.surface_check()
	ctrl.global_rotate(ctrl.xform.basis.y, ctrl.Char_Input.get_input().x * ctrl.stats.rot_jump * _delta)
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	ctrl.set_previous_values()
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	
func _air_check() -> bool:
	if !ctrl.Char_Input.get_input().y == 0:
		ctrl.reset_shapecast(true)
		transitioned.emit(self, "Player_Air")
		return true
	return false

func _get_faceplant(shape_col_fwd : Array, up_direction : Vector3) -> bool:
	var floor_col = null
	if len(shape_col_fwd) > 0:
		for col in shape_col_fwd:
			if col.collider.is_in_group('floor') or col.collider.is_in_group('pipe'):
				floor_col = col
	if floor_col and up_direction.dot(Vector3.UP) < 0.5:
		var _normal = floor_col.normal
		var _dot = _normal.dot(up_direction)
		if _dot <= 0.5:
			print("Fall Faceplant: " + str(_dot))
			transitioned.emit(self, "Player_Fall")
			return true
	return false
	
func _grind_lip_check() -> bool:
	if !input.get_input_grind():
		return false
	if ctrl.get_can_grind():
		transitioned.emit(self, "Player_Grind")
		return true
	elif ctrl.get_can_lip():
		transitioned.emit(self, "Player_Lip")
		return true
	return false

func _fall_check() -> bool:
	if fall.get_fall_faceplant(ctrl.shape_col_fwd, ctrl.up_direction):
		transitioned.emit(self, "Player_Fall")
		return true
	return false
