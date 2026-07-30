extends CharacterState

func enter() -> void:
	input.input_buffer.clear()
	
func exit() -> void:
	pass

func physics_update(_delta : float):
	ctrl.surface_check(false)
	ctrl.set_path()	
	_ground_movement(_delta)
	ctrl.set_previous_values()
	
	_pipesnap_check()
	_ground_check()
	_handle_jump()	
	
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	if input.can_jump():
		ctrl.apply_floor_snap()
	
	anim.animation_handler_ground_pipe(_delta, ctrl.velocity)
	tricks.set_combo_cooldown(_delta)

func _ground_movement(_delta) -> void: 	
	ctrl.last_ground_transform = ctrl.global_transform
	if input.get_input().y < 0:
		ctrl.velocity *= GlobalSettings.GROUND_SLOWDOWN
		ctrl.global_rotate(ctrl.xform.basis.y, input.get_input().x * ctrl.stats.rot_kickturn * _delta)
	else:
		ctrl.global_rotate(ctrl.xform.basis.y, input.get_input().x * ctrl.stats.rot * _delta)
	if input.get_input().y >= 0 and ctrl.velocity.length() < ctrl.stats.max_vel/8 and LibHelpers.forward_velocity(ctrl.velocity, ctrl.up_direction).length() > 0.1 or input.get_input().y > 0:
		ctrl.velocity += ctrl.xform.basis.z * ctrl.stats.acc * 0.25
	if (input.get_input().z > 0 and ctrl.velocity.length() <= ctrl.stats.max_vel and input.get_input().y != -1) or (input.get_input().z < 0 and ctrl.velocity.length() >= -ctrl.stats.max_vel):
		ctrl.velocity += ctrl.xform.basis.z * input.get_input().z * ctrl.stats.acc
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	ctrl.velocity = LibHelpers.kill_orthogonal_velocity(ctrl.xform, ctrl.velocity)

func _handle_jump() -> void:
	if input.get_input_jump():
		ctrl.velocity += Vector3.UP * ctrl.stats.jump_vel
		input.set_jump_cooldown()
		
		transitioned.emit(self, "Player_Air")
		
func _pipesnap_check() -> void:
	var _pipesnap : Dictionary = ctrl.get_pipesnap()
	if !_pipesnap.valid == true:
		return
	if _pipesnap.air == false:
		transitioned.emit(self, "Player_Pipesnap")
	else:
		ctrl.velocity -= ctrl.up_direction * 0.5
		transitioned.emit(self, "Player_Air")	
				
func _ground_check() -> void:
	if ctrl.shape_col_ground:
		var _coll_info = ctrl.shape_col_ground[0].collider
		if _coll_info.is_in_group('floor'):
			transitioned.emit(self, "Player_Ground")
			return
	else:
		transitioned.emit(self, "Player_Air")
