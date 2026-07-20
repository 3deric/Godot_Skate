extends PlayerState

func enter():
	char_ctrl.can_grind = true
	
func exit():
	char_ctrl.can_grind = false
	
func physics_update(_delta : float):
	_grind_movement(_delta)

func _grind_movement(_delta) -> void: 	
	char_ctrl.curve_snap = LibHelpers.get_path_position(char_ctrl.path, char_ctrl.path_offset)
	char_ctrl.path_offset += char_ctrl.path_vel * _delta
	if char_ctrl.path_closed:
		char_ctrl.path_offset = LibHelpers.wrap_curve(char_ctrl.path, char_ctrl.path_offset)
	char_ctrl.curve_tangent = lerp(char_ctrl.curve_tangent, LibHelpers.get_path_tangent(char_ctrl.path, char_ctrl.path_offset), _delta * GlobalSettings.TANGENT_LERP_SPD)
	char_ctrl.position = char_ctrl.curve_snap
	char_ctrl.up_direction =  LibHelpers.get_path_upvector(char_ctrl.path, char_ctrl.path_offset)
	var _target = char_ctrl.global_position + char_ctrl.curve_tangent * char_ctrl.path_dir
	if _target != char_ctrl.position:
		char_ctrl.look_at(_target, char_ctrl.up_direction)
	char_ctrl.velocity = char_ctrl.xform.basis.z * char_ctrl.path_vel * char_ctrl.path_dir
	char_ctrl._balance_logic(_delta, 0)
