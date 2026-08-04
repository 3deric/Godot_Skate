extends CharacterState

func enter():
	tricks.set_start_air()
	
func exit():
	pass

func physics_update(_delta : float):
	ctrl.surface_check()
	_pipe_snap_movement(_delta)
	ctrl.set_previous_values()
	_pipe_end_check()
	_ground_check()
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	tricks.set_air_trick()
	_grind_lip_check()

func _pipe_snap_movement(_delta) -> void: 
	ctrl.curve_snap = LibHelpers.get_path_position(ctrl.path, ctrl.path_offset)
	ctrl.global_rotate(ctrl.xform.basis.y, ctrl.Char_Input.get_input().x * ctrl.stats.rot_jump * _delta)
	ctrl.path_offset += ctrl.path_vel * _delta
	if ctrl.path_closed:
		ctrl.path_offset = LibHelpers.wrap_curve(ctrl.path, ctrl.path_offset)
	ctrl.curve_tangent = lerp(ctrl.curve_tangent, LibHelpers.get_path_tangent(ctrl.path, ctrl.path_offset), _delta * GlobalSettings.TANGENT_LERP_SPD)
	ctrl.up_direction = LibHelpers.pipe_snap_up_dir(ctrl.curve_tangent, ctrl.last_up_dir, ctrl.pipe_snap_flip)
	ctrl.position = Vector3(ctrl.curve_snap.x, ctrl.position.y, ctrl.curve_snap.z) + ctrl.up_direction * GlobalSettings.PIPESNAP_OFFSET
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	ctrl.velocity = LibHelpers.kill_pipe_orthogonal_velocity(ctrl.velocity, ctrl.curve_tangent)

func _pipe_end_check() -> void:
	if !LibHelpers.get_stick_curve(ctrl.path,  ctrl.path_offset, 0.1) and !ctrl.path_closed:
		var newUpDir : Vector3 = Vector3.UP.cross(ctrl.curve_tangent)
		if ctrl.pipe_snap_flip:
			newUpDir*=-1
		if(newUpDir != Vector3.ZERO):
			ctrl.up_direction = (newUpDir + ctrl.last_up_dir)/2
		else:
			ctrl.up_direction = ctrl.last_up_dir
		ctrl.set_path_null()
		transitioned.emit(self, "Player_Pipesnap_Air")

func _ground_check() -> void:
	if ctrl.position.y < ctrl.curve_snap.y:
		ctrl.reset_shapecast(true)
		ctrl.set_path_null()
		transitioned.emit(self, "Player_Pipe")
		
func _grind_lip_check() -> bool:
	if !input.get_input_grind():
		return false
	if ctrl.path == null:
		return false
	if ctrl.get_can_grind():
		transitioned.emit(self, "Player_Grind")
		return true
	elif ctrl.get_can_lip():
		transitioned.emit(self, "Player_Lip")
		return true
	return false
