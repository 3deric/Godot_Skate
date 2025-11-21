extends Node3D

enum PlayerState {
	RESET, 
	GROUND, 
	PIPE, 
	PIPESNAP, 
	PIPESNAPAIR, 
	AIR, 
	FALL, 
	GRIND, 
	LIP, 
	MANUAL
	}

@onready var character: CharacterBody3D = $".."

var player_state = PlayerState.RESET
var last_player_state = PlayerState.RESET


func set_player_state(new_state : PlayerState):
	player_state = new_state
	

func get_player_state() -> PlayerState:
	return player_state


#func _player_state():
	#if (player_state == PlayerState.FALL):	#dont change the state if fallen
		#return
	#
	#if(player_state == PlayerState.GRIND or player_state == PlayerState.LIP):
		#Ingame_Ui.set_balance_view(true)
		##Collision.disabled = true
		#if path == null:
			#player_state = PlayerState.AIR
			#return
		#if path_closed:
			#return
		#if !LibHelpers.get_stick_curve(path,  path_offset):
			#velocity = xform.basis.z * path_vel * path_dir
			#print("losing pipe")
			#player_state = PlayerState.AIR
			#return
		#return
	#else:
		#Ingame_Ui.set_balance_view(false)
		#
	#if(player_state == PlayerState.PIPESNAP):
		#if !LibHelpers.get_stick_curve(path,  path_offset):
			#player_state = PlayerState.PIPESNAPAIR
			#var newUpDir : Vector3 = Vector3.UP.cross(curve_tangent)
			#if pipe_snap_flip:
				#newUpDir*=-1
			#if(newUpDir != Vector3.ZERO):
				#up_direction = (newUpDir + last_up_dir)/2
			#else:
				#up_direction = last_up_dir
			#return
	#
	#var _closest_path : Path3D = null
	#var pathDist : float = 10000.0
	#if (player_state != PlayerState.GRIND and player_state != PlayerState.LIP):
		#for body : CSGPolygon3D in Area.get_overlapping_bodies():
			#if(body.is_in_group('rampRail')):
				#var currentPath : Path3D = body.get_node(body.get_path_node())
				#var currentOffset : float = LibHelpers.get_closest_curve_offset(currentPath, position)
				#var closestPos : Vector3 = LibHelpers.get_position_on_curve(currentPath, currentOffset)
				#var closestDist : float = position.distance_to(closestPos)
				#if(closestDist < pathDist):
					#pathDist = closestDist
					#_closest_path = currentPath
		#
	#if _closest_path != null:
		#path = _closest_path
		#path_closed = LibHelpers.is_path_closed(path)
		#
		#if input_tricks.x == 1 and player_state != PlayerState.GRIND:
			#path_offset = path.curve.get_closest_offset(position * path.global_transform)
			#curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
			#path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.25)
			#if(curve_tangent == Vector3.ZERO):
				#return
			#_randomize_balance()
			#if(path_dir != 0):
				#path_vel = velocity.project(curve_tangent).length() * path_dir
				#player_state = PlayerState.GRIND
				#return
			#if(path_dir == 0 and player_state != PlayerState.PIPESNAP):
				#player_state = PlayerState.LIP
				#path_offset = path.curve.get_closest_offset(position * path.global_transform)
				#lip_start_up = up_direction
				#lip_start_vel = velocity
				#curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
				#var dir : Vector3 = curve_tangent.cross(Vector3(0,1,0))
				#if(xform.basis.y.dot(dir) > 0):
					#dir *= Vector3(-1,-1,-1)
				#lip_start_dir = dir
				#return
	#if ray_ground == {}:	#behavior while in air, or sticked to a pipe
		#if(last_player_state == PlayerState.PIPE and input_tricks.z == 0 and input.y == 0):
			#if path != null:
				#print(path)
				#path_offset = path.curve.get_closest_offset(position * path.global_transform)
				#curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
				#path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.1)
				#path_vel = velocity.project(curve_tangent * Vector3(1,0,1)).length() * path_dir
				#var dir : Vector3 = curve_tangent.cross(Vector3(0,1,0))
				#if(xform.basis.y.dot(dir) > 0):
					#pipe_snap_flip = true
				#else:
					#pipe_snap_flip = false
				#if LibHelpers.get_stick_curve(path, path_offset):
					#player_state = PlayerState.PIPESNAP
					#return
		#if(player_state != PlayerState.PIPESNAP and player_state != PlayerState.PIPESNAPAIR):
			#player_state = PlayerState.AIR	
	#if (player_state == PlayerState.AIR):
		#if is_on_floor():
			#player_state = PlayerState.GROUND	
	#if ray_ground != {}:
		#var _coll_info = null
		#_coll_info = ray_ground["collider"]
		#if ray_ground["normal"].dot(xform.basis.y) < 0.5:
			#return
		#if _coll_info.is_in_group('pipe'):
			#player_state = PlayerState.PIPE
			#path = null
			#return
		#if _coll_info.is_in_group('floor'):
			#player_state = PlayerState.GROUND
			#path = null
			#return
