extends PlayerState

func enter() -> void:
	char_ctrl.top_level = false
	char_ctrl.Char_Animation.init(false)
	
func exit() -> void:
	char_ctrl.top_level = true

func physics_update(_delta : float) -> void:
	_setup_movement(_delta)

func _setup_movement(_delta) -> void: 	
	char_ctrl.global_rotate(char_ctrl.xform.basis.y, char_ctrl.Char_Input.get_input().x * char_ctrl.stats.rot_setup * _delta)
