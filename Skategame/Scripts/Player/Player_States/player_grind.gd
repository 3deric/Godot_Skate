extends PlayerState

func enter():
	char_ctrl.Char_Tricks._start_trick(char_ctrl.Char_Tricks.available_grind_tricks)	
	char_ctrl.reset_shapecast(false)
	char_ctrl.Char_Tricks.performed_olli = false
	char_ctrl.can_grind = true
	char_ctrl.randomize_balance()
	
func exit():
	char_ctrl.can_grind = false
	char_ctrl.reset_shapecast(true)
	
func physics_update(_delta : float):
	_grind_movement(_delta)
	char_ctrl.last_up_dir = char_ctrl.up_direction
	char_ctrl.last_vel = char_ctrl.velocity
	_handle_jump()	
	char_ctrl.set_char_up_direction()
	char_ctrl.global_transform = LibHelpers.align(char_ctrl.global_transform, char_ctrl.up_direction)

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
	char_ctrl.balance_logic(_delta, 0)
	
func _handle_jump() -> void:
	pass
