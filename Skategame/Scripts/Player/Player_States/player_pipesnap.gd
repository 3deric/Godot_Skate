extends PlayerState

func enter():
	char_ctrl.can_air = true
	
func exit():
	char_ctrl.can_air = false

func physics_update(_delta : float):
	char_ctrl.surface_check()
	_pipe_snap_movement(_delta)
	char_ctrl.set_previous_values()
	_ground_check()
	char_ctrl.set_char_up_direction()
	char_ctrl.global_transform = LibHelpers.align(char_ctrl.global_transform, char_ctrl.up_direction)
	char_ctrl.move_and_slide()

func _pipe_snap_movement(_delta) -> void: 
	char_ctrl.curve_snap = LibHelpers.get_path_position(char_ctrl.path, char_ctrl.path_offset)
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_jump * _delta)
	char_ctrl.path_offset += char_ctrl.path_vel * _delta
	if char_ctrl.path_closed:
		char_ctrl.path_offset = LibHelpers.wrap_curve(char_ctrl.path, char_ctrl.path_offset)
	char_ctrl.curve_tangent = lerp(char_ctrl.curve_tangent, LibHelpers.get_path_tangent(char_ctrl.path, char_ctrl.path_offset), _delta * GlobalSettings.TANGENT_LERP_SPD)
	char_ctrl.up_direction = LibHelpers.pipe_snap_up_dir(char_ctrl.curve_tangent, char_ctrl.last_up_dir, char_ctrl.pipe_snap_flip)
	char_ctrl.position = Vector3(char_ctrl.curve_snap.x, char_ctrl.position.y, char_ctrl.curve_snap.z) + char_ctrl.up_direction * GlobalSettings.PIPESNAP_OFFSET
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	char_ctrl.velocity = LibHelpers.kill_pipe_orthogonal_velocity(char_ctrl.velocity, char_ctrl.curve_tangent)

func _ground_check() -> void:
	if char_ctrl.position.y < char_ctrl.curve_snap.y:
		char_ctrl.reset_shapecast(true)
		transitioned.emit(self, "Player_Pipe")	
