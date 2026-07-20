extends PlayerState

func physics_update(_delta : float):
	_ground_movement(_delta)

func _ground_movement(_delta) -> void: 	
	if char_ctrl.path == null:
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
