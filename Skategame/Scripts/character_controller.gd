class_name CharacterController
extends CharacterBody3D

#player settings
@export var stats : PlayerSettings

#global movement variables
var xform = null
var last_ground_pos : Vector3 = Vector3.ZERO
var last_ground_rot : Vector3 = Vector3.ZERO 
var fall_timer : float = 0.0
var last_up_dir : Vector3 = Vector3.ZERO
var pipe_snap_flip : bool = false
var path_offset : float = 0.0
var path_vel : float = 0.0
var last_vel : Vector3 = Vector3.ZERO
var hor_vel : float = 0.0
var fall_check : float = 0.0
var revert_path : bool = false
var anim_blend : Vector3 = Vector3.ZERO
var shape_col_fwd : Array = []
var shape_col_ground : Array = []
var ray_ground : Dictionary = {}
var on_wall : bool = false
var last_on_wall : bool = false
var is_jump : bool = false
var standing_timer : float = GlobalSettings.STANDING_TIMER

#global object references
@onready var Area : Area3D = get_node('Area3D')
@onready var Collision : CollisionShape3D = get_node('CollisionShape3D')
@onready var Shape_Cast : ShapeCast3D = $ShapeCast3D
@onready var Shape_Cast_Ground : ShapeCast3D = $ShapeCast3DGround
@onready var Camera_Pos: Node3D = $"../Camera_Pos"
@onready var Camera: Camera3D = $"../Camera_Pos/Camera3D"
@onready var Char_Ragdoll : CharacterRagdoll = $Char_Ragdoll
@onready var Char_Statemachine : CharacterStatemachine = $Char_Statemachine
@onready var Char_Animation: CharacterAnimation = $Char_Animation
@onready var Char_Tricks : CharacterTricks = $Char_Tricks
@onready var Char_Input : CharacterInput = $Char_Input 
@onready var Char_Fallcheck : CharacterFallcheck = $Char_Fallcheck
@onready var Ingame_Ui : IngameOverlay = $Ingame_Ui
@onready var Char_Init : CharacterInit = $".."

#grind and lip trick variables
var can_air : bool = false
var can_grind : bool = false
var can_lip : bool = false
var balance_time  : float = 1.0
var balance_angle : float = 0.0 #value between - pi and pi to balance the player on grinds, lips and manuals
var balance_dir : int = 0 #defines balance direction based on last input
var path : Path3D = null
var path_closed : bool = false
var path_dir : int = 0
var lip_start_pos : Vector3 = Vector3.ZERO
var lip_start_up : Vector3 = Vector3.ZERO
var lip_start_vel : Vector3 = Vector3.ZERO
var lip_start_dir : Vector3 = Vector3.ZERO
var curve_snap = Vector3.ZERO
var curve_tangent = Vector3.ZERO

func init_player():
	if Char_Init.is_playing:
		top_level = true
		_reset_player(Char_Init.get_start_position(), Char_Init.get_start_rotation())
		Camera_Pos.global_position = Char_Init.get_start_position()
	else:
		Ingame_Ui.set_fail_view(false)
		Ingame_Ui.set_balance_view(false)
	Char_Animation.init(Char_Init.is_playing)
		
func get_can_grind() -> bool:
	return can_grind
	
func get_can_lip() -> bool:
	return can_lip
	
func get_can_air() -> bool:
	return can_air
	
func _process(delta: float) -> void:
	Char_Animation.set_vis_transform(self, delta, GlobalSettings.INTERP_SPEED)

func _physics_process(delta):
	if !Char_Init.is_playing:
		return
	can_air = false
	can_grind = false
	can_lip = false
	Camera_Pos.global_position = Camera_Pos.position.lerp(global_position, delta * 10)
	if Char_Statemachine.is_player_state(CharStates.State.FALL):
		fall_timer -= delta
		if Char_Input.get_input().y and fall_timer < 0.1:
			_reset_player(last_ground_pos, last_ground_rot)
	xform = global_transform
	_surface_check()
	_player_state()
	_fall_check(delta)
	Char_Animation.animation_handler(self, Char_Input.get_input(), Char_Statemachine.get_player_state(), delta)
	Char_Animation.set_vis_balance(Char_Statemachine.get_player_state(), balance_angle)
	match Char_Statemachine.player_state:
		CharStates.State.FALL:
			return
		CharStates.State.GROUND, CharStates.State.PIPE:
			_check_reverse_motion()
			_standing_timer(delta)
			_ground_movement(delta)
		CharStates.State.AIR:
			_air_movement(delta)
		CharStates.State.PIPESNAP:
			_pipe_snap_movement(delta)
			_check_bounce_path()
		CharStates.State.PIPESNAPAIR:
			_pipe_snap_air_movement(delta)
		CharStates.State.GRIND:
			_grind_movement(delta)		
			_check_bounce_path()
		CharStates.State.LIP:
			_lip_movement(delta)
	_wall_bounce()
	if Char_Input.get_input_jump():
		if !is_jump:
			_handle_jump()
	global_transform = LibHelpers.align(global_transform, up_direction)
	last_up_dir = up_direction
	last_vel = velocity
	_set_up_direction()
	if !Char_Statemachine.is_player_state(CharStates.State.GRIND) or !Char_Statemachine.is_player_state(CharStates.State.LIP):
		move_and_slide()
	if Char_Input.can_jump() and Char_Statemachine.is_player_state(CharStates.State.GROUND):
		apply_floor_snap()
		
		
func _player_state() -> void:
	if Char_Statemachine.is_player_state(CharStates.State.FALL):	#dont change the state if fallen
		return
	if Char_Statemachine.is_player_state(CharStates.State.PIPESNAPAIR):
		if abs(Char_Input.input.y) > 0.5:
			Char_Statemachine.set_player_state(CharStates.State.AIR)
			return
	Char_Statemachine.set_last_player_state()
	if Char_Statemachine.is_player_state(CharStates.State.GRIND) or Char_Statemachine.is_player_state(CharStates.State.LIP):
		Ingame_Ui.set_balance_view(true)
		if path == null:
			Char_Statemachine.set_player_state(CharStates.State.AIR)
			return
		if path_closed:
			return
		if !LibHelpers.get_stick_curve(path,  path_offset, 0.05) and  !Char_Statemachine.is_player_state(CharStates.State.LIP):
			velocity = xform.basis.z * path_vel * path_dir
			Char_Statemachine.set_player_state(CharStates.State.AIR)
			return
		return
	else:
		Ingame_Ui.set_balance_view(false)
		
	if Char_Statemachine.is_player_state(CharStates.State.PIPESNAP):
		if !LibHelpers.get_stick_curve(path,  path_offset, 0.1) and !path_closed:
			Char_Statemachine.set_player_state(CharStates.State.PIPESNAPAIR)
			var newUpDir : Vector3 = Vector3.UP.cross(curve_tangent)
			if pipe_snap_flip:
				newUpDir*=-1
			if(newUpDir != Vector3.ZERO):
				up_direction = (newUpDir + last_up_dir)/2
			else:
				up_direction = last_up_dir
			return
	var _closest_path : Path3D = LibHelpers.get_closest_path(Area, position)	
	if _closest_path != null:
		if !Char_Statemachine.is_player_state(CharStates.State.PIPESNAP):
			path = _closest_path
			path_closed = LibHelpers.is_path_closed(path)
			path_offset = path.curve.get_closest_offset(position * path.global_transform)
			curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
			path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.25)
		if !Char_Statemachine.is_player_state(CharStates.State.GRIND) and !Char_Statemachine.is_player_state(CharStates.State.LIP):
			var _grind_start : Dictionary = LibHelpers.start_grind(velocity, path, path_offset)
			var _lip_start : Dictionary = LibHelpers.start_lip(xform, velocity, path, path_offset)
			if _grind_start.valid:
				if !Char_Statemachine.is_player_state(CharStates.State.PIPESNAP):
					path_vel = _grind_start.vel
					curve_tangent = _grind_start.tan
					path_dir = _grind_start.dir
				can_grind = true
			elif _lip_start.valid:
				var _curve = path.curve
				lip_start_pos = _lip_start.pos
				curve_tangent = _lip_start.tan
				lip_start_dir = _lip_start.dir
				lip_start_vel = _lip_start.vel
				lip_start_up = _lip_start.up
				can_lip = true
			_randomize_balance()
	if !shape_col_ground: #behavior while in air, or sticked to a pipe
		if Char_Statemachine.is_last_player_state(CharStates.State.PIPE) and Char_Input.get_input().y == 0 and path:
			var _pipe_snap : Dictionary = LibHelpers.start_pipesnap(xform, velocity, path, path_offset)
			var _stick = LibHelpers.get_stick_curve(path, path_offset, 1.0)
			if path_closed: #always set stick to true when the path is closed
				_stick = true
			if _pipe_snap.valid  and xform.basis.z.dot(Vector3.UP) >= 0.1 and _stick:
				curve_tangent = _pipe_snap.tan
				path_dir = _pipe_snap.dir
				path_vel = _pipe_snap.vel
				pipe_snap_flip = _pipe_snap.flip
				Char_Statemachine.set_player_state(CharStates.State.PIPESNAP)
				return			
		if !Char_Statemachine.is_player_state(CharStates.State.PIPESNAP) and !Char_Statemachine.is_player_state(CharStates.State.PIPESNAPAIR):
			Char_Statemachine.set_player_state(CharStates.State.AIR)
			if Char_Statemachine.is_last_player_state(CharStates.State.PIPE):
				if xform.basis.z.dot(Vector3.UP) > 0.5:
					velocity += xform.basis.z * stats.jump_vel * 0.15 - up_direction.slide(Vector3.UP) * 0.5
					return
			if Char_Statemachine.is_last_player_state(CharStates.State.GROUND):
				if xform.basis.z.dot(Vector3.UP) > 0.5:
					velocity += Vector3.UP * stats.jump_vel * 0.25
					return
			return
	if Char_Statemachine.is_player_state(CharStates.State.AIR):
		if is_on_floor() and !Char_Statemachine.is_player_state(CharStates.State.GROUND):
			Char_Statemachine.set_player_state(CharStates.State.GROUND)
			is_jump = false
	if shape_col_ground:
		var _coll_info = shape_col_ground[0].collider
		if _coll_info.is_in_group("wall"):
			return
		#if ray_ground.normal.dot(xform.basis.y) < 0.5:
			#return
		if _coll_info.is_in_group('pipe') and !Char_Statemachine.is_player_state(CharStates.State.PIPE):
			Char_Statemachine.set_player_state(CharStates.State.PIPE)
			path = null
			is_jump = false
			return
		if up_direction.dot(Vector3.UP) < 0.5:
			return
		if _coll_info.is_in_group('floor') and !Char_Statemachine.is_player_state(CharStates.State.GROUND):
			Char_Statemachine.set_player_state(CharStates.State.GROUND)
			path = null
			is_jump = false
			return

func _surface_check() -> void:
	var speed : float = velocity.length()
	var basis_y : Vector3 = xform.basis.y
	var forward_dir : Vector3 = Vector3.ZERO
	
	var is_grind := Char_Statemachine.is_player_state(CharStates.State.GRIND)
	var is_pipe_snap := Char_Statemachine.is_player_state(CharStates.State.PIPESNAP)
	var is_ground := Char_Statemachine.is_player_state(CharStates.State.GROUND)
	var is_pipe := Char_Statemachine.is_player_state(CharStates.State.PIPE)

	var move_clamp : float = min(speed, 0.25)

	if is_grind or is_pipe_snap:
		forward_dir = curve_tangent * -path_dir * move_clamp
	else:
		forward_dir = LibHelpers.horizontal_velocity(velocity).normalized() * move_clamp
	
	if Char_Input.can_jump():
		var ray_dist : float = (GlobalSettings.RAY_GROUND_DIST if (is_ground or is_pipe) else GlobalSettings.RAY_GROUND_AIR_DIST)
		var shape_ground_offset : float =  (GlobalSettings.SHAPE_GROUND_DIST if (is_ground or is_pipe) else GlobalSettings.SHAPE_GROUND_AIR_DIST)
		
		Shape_Cast_Ground.target_position = to_local(position -basis.y * ray_dist)
		shape_col_ground = Shape_Cast_Ground.collision_result
		ray_ground = LibHelpers.raycast(position + basis_y * 0.05, -basis.y, ray_dist, self)
		if ray_ground and ray_ground.collider.is_in_group("wall"):
			ray_ground = {}
		if shape_col_ground:
			if shape_col_ground[0].normal.dot(up_direction) < 0.75:
				print(shape_col_ground[0].normal)
				shape_col_ground = []
	else:
		shape_col_ground = []
		ray_ground = {}
	Shape_Cast.target_position = to_local(position + forward_dir * GlobalSettings.SHAPE_CAST_OFFSET_MULTIPLIER)
	shape_col_fwd = Shape_Cast.collision_result

func _set_up_direction() -> void:
	if shape_col_ground:
		if !shape_col_ground[0].collider.is_in_group("wall"):
			up_direction = shape_col_ground[0].normal
	else:
		up_direction = last_up_dir	
	if !shape_col_ground and is_on_floor():
		up_direction = get_floor_normal()

func set_fall(_fall_reason, _fall_value) -> void:
	Char_Tricks.set_clear_tricks()
	Char_Ragdoll.set_start_simulation(last_vel)
	Char_Statemachine.set_player_state(CharStates.State.FALL)
	Ingame_Ui.set_fail_view(true)
	fall_timer = GlobalSettings.FALL_TIMER
	
func _reset_player(_pos, _rot) -> void:
	Ingame_Ui.set_fail_view(false)
	Ingame_Ui.set_balance_view(false)
	Char_Ragdoll.set_end_simulation()
	Char_Animation.reset_vis_transform(self)
	standing_timer = GlobalSettings.STANDING_TIMER
	up_direction = Vector3.UP
	velocity = Vector3.ZERO
	last_vel = Vector3.ZERO
	global_position = _pos
	global_rotation = _rot
	Camera_Pos.global_position = _pos
	balance_angle = 0.0
	Char_Statemachine.reset_player_state()
	Char_Input.reset()

func _ground_movement(delta) -> void: 	
	if Char_Statemachine.is_player_state(CharStates.State.GROUND) and path == null:
		last_ground_pos = global_position
		last_ground_rot = global_rotation
	if Char_Input.get_input().y < 0:
		velocity *= GlobalSettings.GROUND_SLOWDOWN
		global_rotate(xform.basis.y, Char_Input.get_input().x * stats.rot_kickturn * delta)
	else:
		global_rotate(xform.basis.y, Char_Input.get_input().x * stats.rot * delta)
	if Char_Input.get_input().y >= 0 and velocity.length() < stats.max_vel/8 and LibHelpers.forward_velocity(velocity, up_direction).length() > 0.1 or Char_Input.get_input().y > 0:
		velocity +=xform.basis.z * stats.acc * 0.25
	if (Char_Input.get_input().z > 0 and velocity.length() <= stats.max_vel and Char_Input.get_input().y != -1) or (Char_Input.get_input().z < 0 and velocity.length() >= -stats.max_vel):
		velocity += xform.basis.z * Char_Input.get_input().z * stats.acc
	velocity.y -= GlobalSettings.GRAVITY * delta
	velocity = LibHelpers.kill_orthogonal_velocity(xform, velocity)

func _air_movement(_delta) -> void: 	
	can_air = true
	var _rot_delta = Char_Input.get_input().x * stats.rot_jump * _delta
	global_rotate(xform.basis.y, _rot_delta)
	velocity.y -= GlobalSettings.GRAVITY * _delta
	up_direction = lerp(up_direction,Vector3.UP, _delta * GlobalSettings.UP_ALIGN_SPEED)
	
func _pipe_snap_movement(delta) -> void: 
	if !path:
		return
	can_air = true
	global_rotate(xform.basis.y, Char_Input.get_input().x * stats.rot_jump * delta)
	curve_snap = LibHelpers.get_path_position(path, path_offset)
	path_offset += path_vel * delta
	if path_closed:
		path_offset = LibHelpers.wrap_curve(path, path_offset)
	curve_tangent = lerp(curve_tangent, LibHelpers.get_path_tangent(path, path_offset), delta * GlobalSettings.TANGENT_LERP_SPD)
	up_direction = LibHelpers.pipe_snap_up_dir(curve_tangent, last_up_dir, pipe_snap_flip)
	position = Vector3(curve_snap.x, position.y, curve_snap.z) + up_direction * GlobalSettings.PIPESNAP_OFFSET
	velocity.y -= GlobalSettings.GRAVITY * delta
	velocity = LibHelpers.kill_pipe_orthogonal_velocity(velocity, curve_tangent)

func _pipe_snap_air_movement(delta) -> void:
	can_air = true
	global_rotate(xform.basis.y, Char_Input.get_input().x * stats.rot_jump * delta)
	velocity.y -= GlobalSettings.GRAVITY * delta

func _grind_movement(delta) -> void: 	
	if !path:
		return
	curve_snap = LibHelpers.get_path_position(path, path_offset)
	path_offset += path_vel * delta
	if path_closed:
		path_offset = LibHelpers.wrap_curve(path, path_offset)
	curve_tangent = lerp(curve_tangent, LibHelpers.get_path_tangent(path, path_offset), delta * GlobalSettings.TANGENT_LERP_SPD)
	position = curve_snap
	up_direction =  LibHelpers.get_path_upvector(path, path_offset)
	var _target = global_position + curve_tangent * path_dir
	if _target != position:
		look_at(_target, up_direction)
	velocity = xform.basis.z * path_vel * path_dir
	_balance_logic(delta, 0)
	
func _lip_movement(delta) -> void:
	if !path:
		return
	can_lip = true
	var _curve : Curve3D = path.curve
	position = lip_start_pos
	up_direction = lip_start_up
	rotation.y = atan2(lip_start_dir.x,lip_start_dir.z)
	_balance_logic(delta, 1)

func _randomize_balance() -> void:
	balance_time = 1.0
	balance_angle = 0.0
	var _rand : float  = randf()
	if (_rand >= 0.5):
		balance_dir = 1
	else:
		balance_dir = -1

func _balance_logic(delta: float, axis : int) -> void:
	if axis == 0:
		if(Char_Input.get_input().x > 0.6 or Char_Input.get_input().x < -0.6):
			_set_balance_dir(round(Char_Input.get_input().x))
	else:
		if(Char_Input.get_input().y > 0.6 or Char_Input.get_input().y < - 0.6):
			_set_balance_dir(round(-Char_Input.get_input().y))
	balance_time += GlobalSettings.BALANCE_TIME_INC * delta
	balance_angle += GlobalSettings.BALANCE_MULTI * delta * balance_dir * balance_time
	Ingame_Ui.set_balance_value(-balance_angle)	
	
func _set_balance_dir(_dir: int) -> void:
	balance_dir = _dir
	
func _check_reverse_motion() -> void:
	if LibHelpers.forward_velocity(velocity, up_direction).length() < 1.0:
		return
	var revertCheck : float = velocity.normalized().dot(xform.basis.z)
	if revertCheck < 0:
		pass #add revert function
		
func _standing_timer(_delta : float) -> void:
	if velocity.length_squared() < GlobalSettings.STANDING_TIMER_MIN_SPEED:
		standing_timer -= _delta
	else: 
		standing_timer = GlobalSettings.STANDING_TIMER
		
func _check_bounce_path() -> void:
	var wall_col = null
	if len(shape_col_fwd) > 0:
		for col in shape_col_fwd:
			if col.collider.is_in_group('wall'):
				wall_col = col
	
	if wall_col and !revert_path:
		path_vel *= -GlobalSettings.PATH_BOUNCE_MULTI
		path_dir *= -1
		revert_path = true

	if !wall_col:
		revert_path = false

func _fall_check(delta) -> void: #to do, try to move the fall achecks to the corresponding states!
	if Char_Statemachine.is_player_state(CharStates.State.FALL):
		return
	if Char_Statemachine.is_player_state(CharStates.State.GROUND) or Char_Statemachine.is_player_state(CharStates.State.PIPE):
		if Char_Statemachine.is_last_player_state(CharStates.State.GROUND) or Char_Statemachine.is_last_player_state(CharStates.State.PIPE):
			if Char_Fallcheck.get_decelleration(LibHelpers.forward_velocity(velocity, up_direction), LibHelpers.forward_velocity(last_vel, up_direction), delta):
				set_fall("Sudden stop", last_vel.length_squared())
				return
		#if standing_timer > 0:
			#return
		#if Char_Fallcheck.get_stand_perpendicular(up_direction):
			#set_fall("balance issues", up_direction.dot(Vector3.UP))
			#return
	if Char_Statemachine.get_player_state() != Char_Statemachine.get_last_player_state():
		if Char_Statemachine.is_last_player_state(CharStates.State.PIPESNAP) and Char_Statemachine.is_player_state(CharStates.State.PIPESNAPAIR):
			return # dont fall when the player is in air from pipesnap
		if Char_Statemachine.is_last_player_state(CharStates.State.PIPESNAPAIR) and Char_Statemachine.is_player_state(CharStates.State.AIR):	
			return # dont fall when the player is in air from pipesnapair
		if Char_Tricks.get_trick_active():
			set_fall("trick not finished", Char_Tricks.current_trick_duration)
			return
	if Char_Fallcheck.get_out_of_bounds(position):
			set_fall("out of bounds!", position)
			return
	if Char_Statemachine.is_player_state(CharStates.State.GRIND) or Char_Statemachine.is_player_state(CharStates.State.LIP):
		if Char_Fallcheck.get_balance_issues(balance_angle):
			set_fall("balance issues", balance_angle)
			return
	if Char_Statemachine.is_last_player_state(CharStates.State.AIR) or Char_Statemachine.is_last_player_state(CharStates.State.PIPESNAPAIR):
		if Char_Fallcheck.get_faceplant(shape_col_fwd, up_direction):
			set_fall("faceplant", up_direction)
			return
	var _is_ground = Char_Statemachine.is_player_state(CharStates.State.GROUND) or Char_Statemachine.is_player_state(CharStates.State.PIPE)
	var _last_air = Char_Statemachine.is_last_player_state(CharStates.State.AIR) or Char_Statemachine.is_last_player_state(CharStates.State.PIPESNAP)
	if !_is_ground or !_last_air:
		return
	if Char_Fallcheck.get_landed_perpendicular(xform, velocity, up_direction):
		set_fall("perpendicular", velocity.dot(xform.basis.z))
		return

func _wall_bounce() -> void:
	if not (Char_Statemachine.is_player_state(CharStates.State.AIR) or
	Char_Statemachine.is_player_state(CharStates.State.GROUND) or
	Char_Statemachine.is_player_state(CharStates.State.PIPE)):
		on_wall = false
		last_on_wall = false
		return
	var wall_col = null
	if len(shape_col_fwd) > 0:
		for col in shape_col_fwd:
			if col.collider.is_in_group('wall'):
				wall_col = col
	if wall_col:
		var _normal = wall_col.normal
		var _fwd_vel = LibHelpers.forward_velocity(velocity, up_direction)
		var _vel_length = _fwd_vel.length()
		
		var _dot = abs(_normal.dot(_fwd_vel.normalized()))
		if _dot < 0.5:
			return

		if _vel_length > GlobalSettings.WALL_BOUNCE_VEL_THRESH:
			var _reflection = velocity.bounce(_normal)
			velocity = _reflection * GlobalSettings.WALL_BOUNCE_MULTI
			position += _normal * GlobalSettings.WALL_BOUNCE_OFFSET_MULTI
			if velocity.length() > 0.1:
				look_at(global_position - velocity.normalized(), up_direction)
			on_wall = true
			print('Wall bounce! Normal: ', _normal, ' Velocity: ', velocity.length())
		else:
			on_wall = false
	else:
		on_wall = false
	last_on_wall = on_wall		

func _handle_jump() -> void:
	is_jump = true
	match Char_Statemachine.player_state:
		CharStates.State.GROUND, CharStates.State.PIPE:
			velocity += Vector3.UP * stats.jump_vel
			Char_Input.set_jump_cooldown()
		
		CharStates.State.PIPE:
			velocity += xform.basis.z * stats.jump_vel * 0.15 - up_direction.slide(Vector3.UP) * 0.5
			Char_Input.set_jump_cooldown()
		
		CharStates.State.GRIND:
			velocity = xform.basis.z * abs(path_vel)
			velocity += xform.basis.y * stats.jump_vel
			velocity += xform.basis.x * Char_Input.get_dir_before_jump() * GlobalSettings.JUMP_GRIND_DIR_MULTI
			position += xform.basis.y * 0.05
			Char_Input.set_jump_cooldown()
			path = null
		
		CharStates.State.LIP:
			position -= lip_start_dir * balance_dir * 0.5 + xform.basis.y * 0.05
			up_direction = Vector3.UP
			rotation.y = atan2(lip_start_dir.x * -balance_dir, lip_start_dir.z * -balance_dir)
			velocity = xform.basis.z * 0.15 + Vector3.UP * stats.jump_vel * 0.25
			Char_Input.set_jump_cooldown()
			path = null
