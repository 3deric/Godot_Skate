class_name LibHelpers
extends RefCounted


static func raycast(_from: Vector3, _dir: Vector3, _len: float, _player: CharacterBody3D):
	var _spaceState : PhysicsDirectSpaceState3D = _player.get_world_3d().direct_space_state
	var _query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_from, _from + _dir * _len)
	_query.exclude = [_player]
	var _col = _spaceState.intersect_ray(_query)
	return _col
	
static func is_path_closed(_path: Path3D)->bool:
	var _curve = _path.curve
	if _curve == null:
		return false	
	return _curve.closed

static func forward_velocity(_vel : Vector3, _up_direction: Vector3) -> Vector3:
	return _vel.slide(_up_direction)
	
static func horizontal_velocity(_vel : Vector3) -> Vector3:
	return _vel.slide(Vector3.UP)
	
static func get_path_tangent(_path: Path3D, _offset: float): #returns the curve tangent
	var _lastOffset : float = _offset + 0.01
	var _curvePos : Vector3 = _path.curve.sample_baked(_offset, true)
	var _lastCurvePos : Vector3 = _path.curve.sample_baked(_lastOffset, true)
	var _tangent : Vector3 = (_curvePos - _lastCurvePos).normalized()
	return _tangent
		
static func get_path_dir(_tangent: Vector3, _vel: Vector3, _treshold): #direction along curve based on start pos
	var _pathDir : float = _tangent.dot(_vel.normalized())
	if(_pathDir > _treshold):
		return  -1
	if(_pathDir < -_treshold):
		return 1
	else:
		return 0

static func get_closest_curve_offset(_path: Path3D, _pos: Vector3):
	var _curve: Curve3D = _path.curve
	var _pathTransform: Transform3D = _path.global_transform
	var _localPos: Vector3 = _pos * _pathTransform
	var _offset: float = _curve.get_closest_offset(_localPos)
	return _offset
		
static func get_position_on_curve(_path: Path3D, _offset):
	var _curve: Curve3D = _path.curve
	var _curvePos: Vector3 = _curve.sample_baked(_offset, true)
	return _curvePos
	
static func get_stick_curve(_path: Path3D,_offset: float):
	var _curve: Curve3D = _path.curve
	if(_offset <= 0.1 or _offset >= _curve.get_baked_length() -.1):
		return false
	else:
		return true

static func wrap_curve(_path : Path3D, _offset : float) -> float:
	var _curve : Curve3D = _path.curve
	_offset = wrapf(_offset, 0.0, _curve.get_baked_length())
	return _offset

static func pipe_snap_up_dir(_curveTangent : Vector3, _last_up_dir, _pipe_snap_flip : bool) -> Vector3: #calculate upvector while snapped to a pipe
	var _newUpDir : Vector3 = Vector3.UP.cross(_curveTangent)
	if _pipe_snap_flip:
		_newUpDir *= -1
	if(_newUpDir != Vector3.ZERO):
		return _newUpDir
	else:
		return _last_up_dir
			
static func limit_velocity(_vel : Vector3, _max_vel : float):
	if _vel.length() > _max_vel:
		return _vel.normalized() * _max_vel
		
static func kill_orthogonal_velocity(_xForm : Transform3D, _vel: Vector3) -> Vector3: 	#remove orthogonal component of velocity
	var _fwdVel : Vector3 = _xForm.basis.z * _vel.dot(_xForm.basis.z)
	var _ortVel : Vector3 = _xForm.basis.x * _vel.dot(_xForm.basis.x)
	var _upVel : Vector3 = _xForm.basis.y  * _vel.dot(_xForm.basis.y)
	var _velocity :Vector3 = _fwdVel + _ortVel * 0.1 + _upVel
	return _velocity

static func kill_pipe_orthogonal_velocity(_vel: Vector3, _tangent: Vector3):
	var _newVel : Vector3 = _vel.dot(_tangent) * _tangent
	_newVel.y = _vel.y
	var _velocity : Vector3 = _newVel
	return _velocity

static func align(_xForm, _newUp):
	var current_up = _xForm.basis.y
	var target_up = _newUp.normalized()
	if current_up.dot(target_up) > 0.999:
		return _xForm
	var rotation_axis = current_up.cross(target_up)
	if rotation_axis.length() < 0.001:
		rotation_axis = Vector3(1, 0, 0)
	var rotation_angle = current_up.angle_to(target_up)
	var rotation_quat = Quaternion(rotation_axis.normalized(), rotation_angle)
	_xForm.basis = Basis(rotation_quat) * _xForm.basis
	_xForm.basis = _xForm.basis.orthonormalized()	
	return _xForm

static func revert_motion():
	pass
	#global_rotate(xform.basis.y, PI)
