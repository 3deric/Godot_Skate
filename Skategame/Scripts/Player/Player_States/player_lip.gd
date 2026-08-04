extends CharacterState

func enter():
	tricks.set_lip_trick()
	tricks.performed_olli = false
	ctrl.reset_shapecast(false)
	ctrl.randomize_balance()
	
func exit():
	ctrl.set_path_null()
	ctrl.reset_shapecast(true)
	anim.reset_vis_balance()

func physics_update(_delta : float):
	ctrl.set_previous_values()
	ctrl.set_up_alignment()
	_lip_movement(_delta)
	anim.set_vis_balance(1, ctrl.balance_angle)
	if ctrl.balance_logic(_delta, 1):
		_handle_fall()
		return
	if _handle_jump():
		return
	tricks.set_lip_trick()

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
