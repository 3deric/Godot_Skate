extends PlayerState

func enter():
	char_ctrl.can_air = true
	
func exit():
	char_ctrl.can_air = false

func physics_update(_delta : float):
	char_ctrl.surface_check()
	
	_air_movement(_delta)
	
	char_ctrl.last_up_dir = char_ctrl.up_direction
	char_ctrl.last_vel = char_ctrl.velocity
	
	_ground_check()
	
	char_ctrl.set_char_up_direction()
	char_ctrl.global_transform = LibHelpers.align(char_ctrl.global_transform, char_ctrl.up_direction)
	char_ctrl.move_and_slide()

func _air_movement(_delta) -> void: 	
	var _rot_delta = char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_jump * _delta
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, _rot_delta)
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	char_ctrl.up_direction = lerp(char_ctrl.up_direction,Vector3.UP, _delta * GlobalSettings.UP_ALIGN_SPEED)

func _ground_check() -> void:
	if char_ctrl.shape_col_ground:
		var _coll_info = char_ctrl.shape_col_ground[0].collider
		if _coll_info.is_in_group("wall"):
			return
		if _coll_info.is_in_group('pipe'):
			transitioned.emit(self, "Player_Pipe")
			return
		if char_ctrl.up_direction.dot(Vector3.UP) < 0.5:
			return
		if _coll_info.is_in_group('floor'):
			transitioned.emit(self, "Player_Ground")
