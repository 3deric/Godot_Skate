extends PlayerState

func enter():
	char_ctrl.can_lip = true
	
func exit():
	char_ctrl.can_lip = false

func physics_update(_delta : float):
	_lip_movement(_delta)

func _lip_movement(_delta) -> void:
	var _curve : Curve3D = char_ctrl.path.curve
	char_ctrl.position = char_ctrl.lip_start_pos
	char_ctrl.up_direction = char_ctrl.lip_start_up
	char_ctrl.rotation.y = atan2(char_ctrl.lip_start_dir.x,char_ctrl.lip_start_dir.z)
	char_ctrl._balance_logic(_delta, 1)
