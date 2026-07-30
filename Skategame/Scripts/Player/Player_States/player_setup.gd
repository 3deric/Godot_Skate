extends CharacterState

func enter() -> void:
	ctrl.top_level = false
	ctrl.Char_Animation.init(false)
	
func exit() -> void:
	ctrl.top_level = true

func physics_update(_delta : float) -> void:
	_setup_movement(_delta)

func _setup_movement(_delta) -> void: 	
	ctrl.global_rotate(ctrl.xform.basis.y, ctrl.Char_Input.get_input().x * ctrl.stats.rot_setup * _delta)
