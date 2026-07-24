extends PlayerState

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func physics_update(_delta : float):
	char_ctrl.surface_check()
	char_ctrl.set_path()	
	_ground_movement(_delta)
	char_ctrl.set_previous_values()
	
	_pipesnap_check()
	_ground_check()
	_handle_jump()	
	
	char_ctrl.set_char_up_direction()
	char_ctrl.global_transform = LibHelpers.align(char_ctrl.global_transform, char_ctrl.up_direction)
	char_ctrl.move_and_slide()
	if char_ctrl.Char_Input.can_jump():
		char_ctrl.apply_floor_snap()
	
	char_ctrl.Char_Animation.animation_handler_ground_pipe(char_ctrl.velocity, char_ctrl.Char_Input.get_input())

func _ground_movement(_delta) -> void: 	
	char_ctrl.last_ground_transform = char_ctrl.global_transform
	if char_ctrl.Char_Input.get_input().y < 0:
		char_ctrl.velocity *= GlobalSettings.GROUND_SLOWDOWN
		char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_kickturn * _delta)
	else:
		char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot * _delta)
	if char_ctrl.Char_Input.get_input().y >= 0 and char_ctrl.velocity.length() < char_ctrl.stats.max_vel/8 and LibHelpers.forward_velocity(char_ctrl.velocity, char_ctrl.up_direction).length() > 0.1 or char_ctrl.Char_Input.get_input().y > 0:
		char_ctrl.velocity += char_ctrl.xform.basis.z * char_ctrl.stats.acc * 0.25
	if (char_ctrl.Char_Input.get_input().z > 0 and char_ctrl.velocity.length() <= char_ctrl.stats.max_vel and char_ctrl.Char_Input.get_input().y != -1) or (char_ctrl.Char_Input.get_input().z < 0 and char_ctrl.velocity.length() >= -char_ctrl.stats.max_vel):
		char_ctrl.velocity += char_ctrl.xform.basis.z * char_ctrl.Char_Input.get_input().z * char_ctrl.stats.acc
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	char_ctrl.velocity = LibHelpers.kill_orthogonal_velocity(char_ctrl.xform, char_ctrl.velocity)

func _handle_jump() -> void:
	if char_ctrl.Char_Input.get_input_jump():
		char_ctrl.velocity += Vector3.UP * char_ctrl.stats.jump_vel
		char_ctrl.Char_Input.set_jump_cooldown()
		
		transitioned.emit(self, "Player_Air")
		
func _pipesnap_check() -> void:
	var _pipesnap : Dictionary = char_ctrl.get_pipesnap()
	if !_pipesnap.valid == true:
		return
	if _pipesnap.air == false:
		transitioned.emit(self, "Player_Pipesnap")
	transitioned.emit(self, "Player_Air")	
				
func _ground_check() -> void:
	if char_ctrl.shape_col_ground:
		var _coll_info = char_ctrl.shape_col_ground[0].collider
		if _coll_info.is_in_group('floor'):
			transitioned.emit(self, "Player_Ground")
			return
	else:
		transitioned.emit(self, "Player_Air")
