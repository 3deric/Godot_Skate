extends CharacterState

func enter():
	tricks.set_lip_trick()
	tricks.performed_olli = false
	ctrl.reset_shapecast(false)
	ctrl.randomize_balance()
	BalanceOverlay.instance.set_balance_view(true)
	
func exit():
	ctrl.set_path_null()
	ctrl.reset_shapecast(true)
	anim.reset_vis_balance()
	BalanceOverlay.instance.set_balance_view(false)
	input.input_buffer.clear()

func physics_update(_delta : float):
	ctrl.set_previous_values()
	ctrl.set_up_alignment()
	ctrl.balance_logic(_delta, 1)
	_lip_movement(_delta)
	if fall.get_fall_balance(ctrl.balance_angle):
		_handle_fall()
		return
	if _handle_jump():
		return
	anim.set_vis_balance(1, ctrl.balance_angle)

func _lip_movement(_delta) -> void:
	var _curve : Curve3D = ctrl.path.curve
	ctrl.position = ctrl.lip_start_pos
	ctrl.up_direction = ctrl.lip_start_up
	ctrl.rotation.y = atan2(ctrl.lip_start_dir.x,ctrl.lip_start_dir.z)

func _handle_jump() -> bool:
	if input.get_input_jump():
		ctrl.position -= ctrl.lip_start_dir * ctrl.balance_dir * 0.5 + ctrl.xform.basis.y * 0.05
		ctrl.up_direction = Vector3.UP
		ctrl.rotation.y = atan2(ctrl.lip_start_dir.x * -ctrl.balance_dir, ctrl.lip_start_dir.z * -ctrl.balance_dir)
		ctrl.velocity = ctrl.xform.basis.z * 0.15 + Vector3.UP * ctrl.stats.jump_vel * 0.25
		input.set_jump_cooldown()
		transitioned.emit(self, "Player_Air")
		return true
	return false
	
func _handle_fall() -> void:
	print("Fall Balance Issues: " + str(ctrl.balance_angle))
	transitioned.emit(self, "Player_Fall")
