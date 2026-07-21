extends PlayerState

func enter() -> void:
	_reset_player()
	
func exit() -> void:
	pass

func update(delta : float):
	if Input.is_action_just_released("Jump"):
		transitioned.emit(self, "Player_Ground")

func _reset_player() -> void:
	var _transform = char_ctrl.last_ground_transform
	char_ctrl.Ingame_Ui.set_fail_view(false)
	char_ctrl.Ingame_Ui.set_balance_view(false)
	char_ctrl.Char_Ragdoll.set_end_simulation()
	char_ctrl.Char_Animation.reset_vis_transform(char_ctrl)
	char_ctrl.Char_Animation.init(true)
	char_ctrl.standing_timer = GlobalSettings.STANDING_TIMER
	char_ctrl.up_direction = Vector3.UP
	char_ctrl.velocity = Vector3.ZERO
	char_ctrl.last_vel = Vector3.ZERO
	char_ctrl.global_transform = _transform
	char_ctrl.Camera_Pos.global_position = _transform.origin
	char_ctrl.balance_angle = 0.0
	char_ctrl.Char_Input.reset()
