class_name CharacterController
extends CharacterBody3D

#global movement constants
const ACC : float= 0.1
const JUMP_VEL : float = 5.0
const ROT : float= 2.0
const ROT_KICKTURN : float = 4.0
const ROT_JUMP : float= 7.0
const MAX_VEL : float = 12.0
const GRAVITY : float = 15.0
const BALANCE_MULTI : float= 0.75
const PIPESNAP_OFFSET : float = 0.0
const UP_ALIGN_SPEED : float = 10.0

#global movement variables
var xform = null
var last_ground_pos : Vector3 = Vector3.ZERO
var fall_timer : float = 0.0
var last_up_dir : Vector3 = Vector3.ZERO
var pipe_snap_flip : bool = false
var jump_timer : float = 0.0
var path_offset : float = 0.0
var path_vel : float = 0.0
var last_vel : Vector3 = Vector3.ZERO
var hor_vel : float = 0.0
var fall_check : float = 0.0
var revert_path : bool = false
var anim_blend : Vector3 = Vector3.ZERO
var ray_forward : Dictionary = {}
var ray_ground : Dictionary = {}
var ray_path : Dictionary = {}
var ray_down : Dictionary = {}

#global object references
@export var is_playing : bool = false
@onready var Area : Area3D = get_node('Area3D')
@onready var Collision : CollisionShape3D = get_node('CollisionShape3D')
@export var Camera : Camera3D = null
@export var Camera_Pos : Node3D = null
@onready var Char_Ragdoll : CharacterRagdoll = $Char_Ragdoll
@onready var Char_Statemachine : CharacterStatemachine = $Char_Statemachine
@onready var Ingame_Ui : IngameOverlay = $Ingame_Ui

#input variables
var input : Vector3i = Vector3.ZERO #input values
var input_tricks : Vector3i = Vector3.ZERO #input values for tricks

#grind and lip trick variables
var balance_time  : float = 1.0
var balance_angle : float = 0.0 #value between - pi and pi to balance the player on grinds, lips and manuals
var balance_dir : int = 0 #defines balance direction based on last input
var path : Path3D = null
var path_closed : bool = false
var path_dir: int = 0
var lip_start_up: Vector3 = Vector3.ZERO
var lip_start_vel: Vector3 = Vector3.ZERO
var lip_start_dir: Vector3 = Vector3.ZERO
var curve_snap = Vector3.ZERO
var curve_tangent = Vector3.ZERO

func _ready():
	if is_playing:
		_init_player()
		_reset_player(Vector3(-3.149,6.868,18.256) + Vector3.UP * 5.0)
		
		
func _init_player():
	pass
	

func _process(_delta):
	if !is_playing:
		return
	_input_handler()


func _physics_process(delta):
	if !is_playing:
		return
	Camera_Pos.position = Camera_Pos.position.lerp(global_position, delta * 10)
	_input_handler()
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.FALL):
		fall_timer -= delta
	Camera_Pos.position = Camera_Pos.position.lerp(global_position, delta * 10)
	xform = global_transform
	_surface_check()
	_jump_timer(delta)
	_player_state()
	_fall_check()
	match Char_Statemachine.player_state:
		Char_Statemachine.PlayerState.FALL:
			return
		Char_Statemachine.PlayerState.GROUND, Char_Statemachine.PlayerState.PIPE:
			_check_reverse_motion()
			_ground_movement(delta)
		Char_Statemachine.PlayerState.AIR:
			_air_movement(delta)
		Char_Statemachine.PlayerState.PIPESNAP:
			_check_bounce_path(true)
			_pipe_snap_movement(delta)
		Char_Statemachine.PlayerState.PIPESNAPAIR:
			_pipe_snap_air_movement(delta)
		Char_Statemachine.PlayerState.GRIND:
			_check_bounce_path(false)
			_grind_movement(delta)
		Char_Statemachine.PlayerState.LIP:
			_lip_movement(delta)
	global_transform = LibHelpers.align(global_transform, up_direction)
	last_up_dir = up_direction
	last_vel = velocity
	_set_up_direction()
	move_and_slide()
	if jump_timer < 0.1 and Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GROUND):
		apply_floor_snap()
		

func _player_state():
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.FALL):	#dont change the state if fallen
		return
	
	Char_Statemachine.debug_player_state()
	Char_Statemachine.update_last_player_state()
	
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GRIND) or Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.LIP):
		_set_balance_view(true)
		if path == null:
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.AIR)
			return
		if path_closed:
			return
		if !LibHelpers.get_stick_curve(path,  path_offset):
			velocity = xform.basis.z * path_vel * path_dir
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.AIR)
			return
		return
	else:
		_set_balance_view(false)
		
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.PIPESNAP):
		if !LibHelpers.get_stick_curve(path,  path_offset) and !path_closed:
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.PIPESNAPAIR)
			var newUpDir : Vector3 = Vector3.UP.cross(curve_tangent)
			if pipe_snap_flip:
				newUpDir*=-1
			if(newUpDir != Vector3.ZERO):
				up_direction = (newUpDir + last_up_dir)/2
			else:
				up_direction = last_up_dir
			return
	
	var _closest_path : Path3D = null
	var _path_dist : float = 10000.0
	if !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GRIND) and !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.LIP):
		for body : CSGPolygon3D in Area.get_overlapping_bodies():
			if(body.is_in_group('rampRail')):
				var _current_path : Path3D = body.get_node(body.get_path_node())
				var _current_offset : float = LibHelpers.get_closest_curve_offset(_current_path, position)
				var _closest_pos : Vector3 = LibHelpers.get_position_on_curve(_current_path, _current_offset)
				var _closest_dist : float = position.distance_to(_closest_pos)
				if(_closest_dist < _path_dist):
					_path_dist = _closest_dist
					_closest_path = _current_path
		
	if _closest_path != null:
		path = _closest_path
		path_closed = LibHelpers.is_path_closed(path)
		
		if input_tricks.x == 1 and !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GRIND):
			path_offset = path.curve.get_closest_offset(position * path.global_transform)
			curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
			path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.25)
			if(curve_tangent == Vector3.ZERO):
				return
			_randomize_balance()
			if(path_dir != 0):
				path_vel = velocity.project(curve_tangent).length() * path_dir
				Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.GRIND)
				return
			if path_dir == 0 and !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.PIPESNAP):
				Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.LIP)
				path_offset = path.curve.get_closest_offset(position * path.global_transform)
				lip_start_up = up_direction
				lip_start_vel = velocity
				curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
				var dir : Vector3 = curve_tangent.cross(Vector3(0,1,0))
				if(xform.basis.y.dot(dir) > 0):
					dir *= Vector3(-1,-1,-1)
				lip_start_dir = dir
				return
	if ray_ground == {}:	#behavior while in air, or sticked to a pipe
		if Char_Statemachine.is_last_player_state(Char_Statemachine.PlayerState.PIPE) and input_tricks.z == 0 and input.y == 0:
			if path != null:
				print(path)
				path_offset = path.curve.get_closest_offset(position * path.global_transform)
				curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
				path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.1)
				path_vel = velocity.project(curve_tangent * Vector3(1,0,1)).length() * path_dir
				var dir : Vector3 = curve_tangent.cross(Vector3(0,1,0))
				if(xform.basis.y.dot(dir) > 0):
					pipe_snap_flip = true
				else:
					pipe_snap_flip = false
				if LibHelpers.get_stick_curve(path, path_offset):
					Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.PIPESNAP)
					return
		if !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.PIPESNAP) and !Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.PIPESNAPAIR):
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.AIR)
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.AIR):
		if is_on_floor():
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.GROUND)
	if ray_ground != {}:
		var _coll_info = null
		_coll_info = ray_ground["collider"]
		if ray_ground["normal"].dot(xform.basis.y) < 0.5:
			return
		if _coll_info.is_in_group('pipe'):
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.PIPE)
			path = null
			return
		if _coll_info.is_in_group('floor'):
			Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.GROUND)
			path = null
			return


func _surface_check():
	ray_ground = LibHelpers.raycast(position + xform.basis.y * 0.1, xform.basis.y, -0.5, self)
	ray_forward = LibHelpers.raycast(position + xform.basis.y, velocity.normalized().slide(xform.basis.y),0.5, self)
	ray_path = LibHelpers.raycast(position + xform.basis.y * 1.0, curve_tangent * path_dir, -0.5, self)
	ray_down = LibHelpers.raycast(position, Vector3.DOWN, 1.0, self)


func _set_up_direction():
	if ray_ground != {}:	
		up_direction = ray_ground["normal"]
	else:
		up_direction = last_up_dir	


func _fall(_fall_reason, _fall_value):
	print(_fall_reason + ": " + str(_fall_value)+ "last velocity: " + str(last_vel.length()))
	Char_Ragdoll.set_start_simulation(last_vel)
	Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.FALL)
	_set_fail_view(true)
	fall_timer = 2.0
	

func _reset_player(_pos):
	_set_fail_view(false)
	_set_balance_view(false)
	Char_Ragdoll.set_end_simulation()
	up_direction = Vector3.UP
	velocity = Vector3.ZERO
	last_vel = Vector3.ZERO
	global_position = _pos
	global_rotation =  Vector3(0,3.14/2,0)
	Char_Statemachine.reset_player_state()


func _input_handler(): 	#handles player inputs
	input.x = int(Input.is_action_pressed('Left')) - int(Input.is_action_pressed('Right'))
	input.y = int(Input.is_action_pressed('Forward')) - int(Input.is_action_pressed('Backward'))
	input.z = int(Input.is_action_pressed('Jump'))
	input_tricks.x = int(Input.is_action_pressed('Grind'))
	input_tricks.y = int(Input.is_action_pressed('Revert'))
	input_tricks.z = int(Input.is_action_just_released('Jump'))
	if(input.y and Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.FALL) and fall_timer < 0.1):
		_reset_player(last_ground_pos + Vector3.UP * 0.1)


func _ground_movement(delta): 	#movement while grounded
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GROUND):
		last_ground_pos = global_position
	if input.y < 0:
		velocity *= 0.95
		global_rotate(xform.basis.y, input.x * ROT_KICKTURN * delta)
	else:
		global_rotate(xform.basis.y, input.x * ROT * delta)
	if input.y >= 0 and velocity.length() < MAX_VEL/8 and LibHelpers.forward_velocity(velocity, up_direction).length() > 0.1 or input.y > 0:
		velocity +=xform.basis.z * ACC * 0.25
	if((input.z > 0 and velocity.length() <= MAX_VEL and input.y != -1) or (input.z < 0 and velocity.length() >= -MAX_VEL)):
		velocity += xform.basis.z * input.z * ACC
	if input_tricks.z > 0:
		velocity += Vector3.UP * JUMP_VEL
		jump_timer = 1.0
	velocity.y -= GRAVITY * delta
	velocity = LibHelpers.kill_orthogonal_velocity(xform, velocity)


func _air_movement(_delta): 	#movement while in air
	global_rotate(xform.basis.y, input.x * ROT_JUMP * _delta)
	velocity.y -= GRAVITY * _delta
	if ray_down != {}:
		up_direction = lerp(up_direction, ray_down.normal, _delta * UP_ALIGN_SPEED)
	else:
		up_direction = lerp(up_direction,Vector3.UP, _delta * UP_ALIGN_SPEED)
	

func _pipe_snap_movement(delta): 	#movement while snapped to a pipe
	global_rotate(xform.basis.y, input.x * ROT_JUMP * delta)
	var _curve : Curve3D = path.curve
	curve_snap = _curve.sample_baked(path_offset, true)
	path_offset += path_vel * delta
	if path_closed:
		path_offset = LibHelpers.wrap_curve(path, path_offset)
	curve_tangent = (LibHelpers.get_path_tangent(path, path_offset) * Vector3(1,0,1)).normalized()
	up_direction = LibHelpers.pipe_snap_up_dir(curve_tangent, last_up_dir, pipe_snap_flip)
	position = Vector3(curve_snap.x, position.y, curve_snap.z) + up_direction * PIPESNAP_OFFSET
	velocity.y -= GRAVITY * delta
	velocity = LibHelpers.kill_pipe_orthogonal_velocity(velocity, curve_tangent)


func _pipe_snap_air_movement(delta):	#movement when snapped pipe is left in air
	global_rotate(xform.basis.y, input.x * ROT_JUMP * delta)
	velocity.y -= GRAVITY * delta


func _grind_movement(delta) -> void: 	#movement logic while grinding a rail
	var _curve : Curve3D = path.curve
	curve_snap = _curve.sample_baked(path_offset, true)
	path_offset += path_vel * delta
	if path_closed:
		path_offset = LibHelpers.wrap_curve(path, path_offset)
	curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
	position = curve_snap
	up_direction = _curve.sample_baked_up_vector(path_offset)
	var _target = global_position + curve_tangent * path_dir
	if _target != position:
		look_at(_target, up_direction)
	velocity = xform.basis.z * path_vel * path_dir
	if input_tricks.z:
		velocity = xform.basis.z * abs(path_vel)
		velocity += Vector3.UP * input_tricks.z * JUMP_VEL
		velocity += xform.basis.x * balance_dir
		path = null
		return
	_balance_logic(delta, 0)
	

func _lip_movement(delta) -> void:
	var _curve : Curve3D = path.curve
	position = _curve.sample_baked(path_offset)
	up_direction = _curve.sample_baked_up_vector(path_offset)
	rotation.y = atan2(lip_start_dir.x,lip_start_dir.z)
	if(input_tricks.z):
		velocity = velocity.normalized() * -1
		Char_Statemachine.set_player_state(Char_Statemachine.PlayerState.AIR)
		position -= lip_start_dir * balance_dir * 0.5
		velocity = lip_start_vel.normalized() * -1
		up_direction = Vector3.UP
		rotation.y = atan2(lip_start_dir.x * -balance_dir,lip_start_dir.z * -balance_dir)
	_balance_logic(delta, 1)


func _set_balance_view(_enabled : bool) -> void:
	Ingame_Ui.set_balance_view(_enabled)


func _randomize_balance() -> void:
	balance_time = 1.0
	var _rand : float  = randf()
	if (_rand >= 0.5):
		balance_dir = 1
	else:
		balance_dir = -1
		balance_angle = 0


func _balance_logic(delta: float, axis : int):
	if axis == 0:
		if(input.x != 0):
			_set_balance_dir(input.x)
	else:
		if(input.y != 0):
			_set_balance_dir(-input.y)
	balance_time += 0.05 * delta
	balance_angle += BALANCE_MULTI * delta * balance_dir * balance_time
	Ingame_Ui.set_balance_value(-balance_angle)
	
	
func _set_balance_dir(_dir: int):
	balance_dir = _dir
	

func _check_reverse_motion() -> void:
	if LibHelpers.forward_velocity(velocity, up_direction).length() < 1.0:
		return
	var revertCheck : float = velocity.normalized().dot(xform.basis.z)
	if revertCheck < 0:
		LibHelpers.revert_motion()


func _check_bounce_path(air : bool) -> void:
	if ray_path != {} and !revert_path:
		if air:
			path_vel *= -0.1
		else: 
			path_vel *= -1.0
			look_at(global_position + curve_tangent * -path_dir, up_direction)
		path_dir *= -1
		revert_path = true
	if ray_path == {}:
		revert_path = false


func _jump_timer(delta) -> void:
	if jump_timer > 0:
		jump_timer -= delta


func _fall_check() -> void:
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.FALL):
		return
	if Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.GRIND) or Char_Statemachine.is_player_state(Char_Statemachine.PlayerState.LIP):
		if (balance_angle > PI /4 or balance_angle < -PI /4):
			_fall("balance issues", balance_angle)
			return
			
	#if (is_on_wall_only() or is_on_ceiling()) and up_direction.dot(Vector3.UP) < 0.5 and player_state != PlayerState.PIPESNAP:	
		#_fall("Wall", up_direction.dot(Vector3.UP))	
	#	print(get_floor_normal())	
	#	return
	#if is_on_wall_only() and get_wall_normal().dot(up_direction) < 0.1:
	#	_fall("Wall", get_wall_normal().dot(up_direction))	
	#hor_vel = abs(last_vel.slide(xform.basis.y).length())
	#fall_check = abs(xform.basis.z.dot(last_vel.slide(xform.basis.y).normalized()))
	#if (player_state == PlayerState.GROUND or player_state == PlayerState.PIPE) and fall_check < 0.5 and hor_vel > 0.5:
	#	_fall("Floor", fall_check)


func _set_fail_view(enabled : bool) -> void:
	Ingame_Ui.set_fail_view(enabled)
