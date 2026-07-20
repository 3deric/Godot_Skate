extends PlayerState

func enter():
	char_ctrl.can_air = true
	
func exit():
	char_ctrl.can_air = false

func physics_update(_delta : float):
	_air_movement(_delta)

func _air_movement(_delta) -> void: 	
	var _rot_delta = char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_jump * _delta
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, _rot_delta)
	char_ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	char_ctrl.up_direction = lerp(char_ctrl.up_direction,Vector3.UP, _delta * GlobalSettings.UP_ALIGN_SPEED)
