extends CharacterState

func enter():
	ctrl.Char_Tricks._start_trick(ctrl.Char_Tricks.available_grind_tricks)	
	ctrl.reset_shapecast(false)
	ctrl.Char_Tricks.performed_olli = false
	ctrl.randomize_balance()
	
func exit():
	ctrl.reset_shapecast(true)
	
func physics_update(_delta : float):
	_grind_movement(_delta)
	ctrl.last_up_dir = ctrl.up_direction
	ctrl.last_vel = ctrl.velocity
	_handle_jump()	
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)

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
	
func _handle_jump() -> void:
	pass
