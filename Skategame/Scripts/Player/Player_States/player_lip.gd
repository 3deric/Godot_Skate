extends CharacterState

func enter():
	tricks.set_lip_trick()
	tricks.performed_olli = false
	ctrl.reset_shapecast(false)
	ctrl.randomize_balance()
	
func exit():
	ctrl.set_path_null()
	ctrl.reset_shapecast(true)

func physics_update(_delta : float):
	ctrl.set_previous_values()
	ctrl.set_up_alignment()
	_lip_movement(_delta)
	_handle_jump()
	tricks.set_lip_trick()

func _lip_movement(_delta) -> void:
	var _curve : Curve3D = ctrl.path.curve
	ctrl.position = ctrl.lip_start_pos
	ctrl.up_direction = ctrl.lip_start_up
	ctrl.rotation.y = atan2(ctrl.lip_start_dir.x,ctrl.lip_start_dir.z)
	#ctrl._balance_logic(_delta, 1)
