extends CharacterStateGround

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func physics_update(_delta : float):
	_ground_movement(_delta)					
	_handle_jump()	
	_pipesnap_check()
	_grind_lip_check()

func _pipesnap_check() -> void:
	var _pipesnap : Dictionary = ctrl.get_pipesnap()
	if !_pipesnap.valid == true:
		return
	if _pipesnap.air == false:
		transitioned.emit(self, "Player_Pipesnap")
	else:
		ctrl.velocity -= ctrl.up_direction * 0.5
		transitioned.emit(self, "Player_Air")	

func _ground_check() -> void:
	if ctrl.shape_col_ground:
		var _coll_info = ctrl.shape_col_ground[0].collider
		var _coll_normal = ctrl.shape_col_ground[0].normal
		if _coll_info.is_in_group('ground'):
			if ctrl.up_direction.dot(_coll_normal) > 0.995:
				transitioned.emit(self, "Player_Ground")
			return
	else:
		transitioned.emit(self, "Player_Air")
