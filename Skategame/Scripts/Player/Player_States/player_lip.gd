extends CharacterState

func enter():
	pass
	
func exit():
	pass

func physics_update(_delta : float):
	_lip_movement(_delta)

func _lip_movement(_delta) -> void:
	var _curve : Curve3D = ctrl.path.curve
	ctrl.position = ctrl.lip_start_pos
	ctrl.up_direction = ctrl.lip_start_up
	ctrl.rotation.y = atan2(ctrl.lip_start_dir.x,ctrl.lip_start_dir.z)
	ctrl._balance_logic(_delta, 1)
