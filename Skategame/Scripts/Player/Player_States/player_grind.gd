extends CharacterState

func enter():
	ctrl.path_vel = _min_path_vel(ctrl.path_vel)
	tricks.set_grind_trick()
	tricks.performed_olli = false
	ctrl.reset_shapecast(true)
	ctrl.randomize_balance()
	BalanceOverlay.instance.set_balance_view(true, PI/2)
	
func exit():
	ctrl.set_path_null()
	ctrl.reset_shapecast(true)
	anim.reset_vis_balance()
	BalanceOverlay.instance.set_balance_view(false)
	
func physics_update(_delta : float):
	ctrl.set_previous_values()
	ctrl.surface_check(false, true)
	ctrl.set_up_alignment()
	ctrl.balance_logic(_delta, 0)
	ctrl.handle_bounce()
	_grind_movement(_delta)
	if fall.get_fall_balance(ctrl.balance_angle):
		_handle_fall()
		return
	if _handle_jump():
		return
	if _grind_end_check():
		return
	anim.set_vis_balance(0, ctrl.balance_angle)
	tricks.set_grind_trick()

func _grind_movement(_delta) -> void: 	
	ctrl.curve_snap = LibHelpers.get_path_position(ctrl.path, ctrl.path_offset)
	ctrl.path_offset += ctrl.path_vel * _delta
	if ctrl.path_closed:
		ctrl.path_offset = LibHelpers.wrap_curve(ctrl.path, ctrl.path_offset)
	ctrl.curve_tangent = lerp(ctrl.curve_tangent, LibHelpers.get_path_tangent(ctrl.path, ctrl.path_offset), _delta * GlobalSettings.TANGENT_LERP_SPD)
	ctrl.position = ctrl.curve_snap
	ctrl.up_direction =  LibHelpers.get_path_upvector(ctrl.path, ctrl.path_offset)
	var _target = ctrl.global_position + ctrl.curve_tangent * ctrl.path_dir
	if _target != ctrl.position:
		ctrl.look_at(_target, ctrl.up_direction)
	ctrl.velocity = ctrl.xform.basis.z * ctrl.path_vel * ctrl.path_dir
	ctrl.balance_logic(_delta, 0)
	
func _grind_end_check() -> bool:
	if !LibHelpers.get_stick_curve(ctrl.path,  ctrl.path_offset, 0.1) and !ctrl.path_closed:
		ctrl.reset_shapecast(true)
		if ctrl.shape_col_ground:
			var _coll_info = ctrl.shape_col_ground[0].collider
			var _coll_normal = ctrl.shape_col_ground[0].normal
			if _coll_info.is_in_group('pipe'): # check the normal too, to avoid jittering at the end of a elevated grinddable surface
				transitioned.emit(self, "Player_Pipe")
				return true
			else:
				transitioned.emit(self, "Player_Ground")
				return true
		ctrl.velocity += ctrl.up_direction * GlobalSettings.GRIND_END_UP_VEL
		transitioned.emit(self, "Player_Air")
		return true
	return false

func _handle_jump() -> bool:
	if input.get_input_jump():
		ctrl.velocity = ctrl.xform.basis.z * abs(ctrl.path_vel)
		ctrl.velocity += ctrl.xform.basis.y * ctrl.stats.jump_vel
		ctrl.velocity += ctrl.xform.basis.x * input.get_dir_before_jump() * GlobalSettings.JUMP_GRIND_DIR_MULTI
		ctrl.position += ctrl.xform.basis.y * 0.05
		input.set_jump_cooldown()
		transitioned.emit(self, "Player_Air")
		return true
	return false
	
func _handle_fall() -> void:
	print("Fall Balance Issues: " + str(ctrl.balance_angle))
	transitioned.emit(self, "Player_Fall")
	
func _min_path_vel(_vel : float) -> float:
	return max(abs(_vel), GlobalSettings.MIN_GRIND_VEL) * sign(_vel)
