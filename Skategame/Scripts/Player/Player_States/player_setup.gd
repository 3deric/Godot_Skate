extends CharacterState

func enter() -> void:
	_reset()
	
func exit() -> void:
	pass

func physics_update(_delta : float) -> void:
	_setup_movement(_delta)

func _setup_movement(_delta) -> void: 	
	ctrl.global_rotate(ctrl.xform.basis.y, ctrl.Char_Input.get_input().x * ctrl.stats.rot_setup * _delta)

func _reset() -> void:
	ctrl.top_level = false
	ctrl.position = Vector3.ZERO
	ctrl.rotation = Vector3.ZERO
	anim.init(false)
	anim.reset_vis_balance()
