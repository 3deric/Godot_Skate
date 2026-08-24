class_name CharacterFallcheck
extends Node

var recent_max_speed : float = 0.0

func get_fall_balance(balance_angle : float, threshold : float = 4.0) -> bool:
	if abs(balance_angle) > PI / threshold:
		return true
	return false

func get_fall_faceplant(shape_col_fwd : Array, up_direction : Vector3 = Vector3.UP) -> bool:
	var _floor_col = null
	var _normal = Vector3.ZERO
	if len(shape_col_fwd) > 0:
		for col in shape_col_fwd:
			if col.collider.is_in_group('floor') or col.collider.is_in_group('pipe'):
				_floor_col = col
				_normal = _floor_col.normal
	var _dot = _normal.dot(up_direction)
	if _floor_col and _dot < 0.75:	
		print("Fall Faceplant: " + str(_dot))
		return true
	return false

func get_fall_out_of_bounds(position : Vector3) -> bool:
	if position.y < - 100:
		print("Fall Out of Bounds: " + str(position.y))
		return true
	return false
	
func get_fall_landed_perpendicular(xform, velocity : Vector3, up_direction : Vector3) -> bool:
	var _fwd_vel : Vector3 = LibHelpers.forward_velocity(velocity, up_direction)
	if _fwd_vel.length() <= GlobalSettings.PERPENDICULAR_FALL_THRESHOLD:
		return false
	var _perp : Dictionary = LibHelpers.landed_perpendicular(_fwd_vel, xform.basis.z, GlobalSettings.FLOOR_FALL_THRESHOLD)
	if !_perp.valid:
		print("Fall Perpendicular: " + str(_perp.dot))
		return true
	return false

	#
#func get_stand_perpendicular(up_direction : Vector3) -> bool:
	#var _dot = up_direction.dot(Vector3.UP)
	#if _dot < 0.85:
		#print("Fall Perpendicular Stand ", _dot)
		#return true
	#return false
	#
#func get_decelleration(velocity : Vector3, last_vel : Vector3, delta) -> bool:
	#var dec = (velocity - last_vel) / delta
	#if dec.length_squared() > 250000 and velocity.length_squared() < last_vel.length_squared():
		#print("Fall Sudden Stop: " + str(dec))
		#return true
	#return false
	
	#if last_vel.length_squared() > 1 and velocity.length_squared() < 0.5:
		#print(last_vel.length_squared())
		#print("Sudden stop", last_vel.length_squared())
		# might be better to subtract last_vel - vel and then divide by delta
		# to be framerate independent
		#return true
	#return false
