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
const FLOOR_FALL_THRESHOLD : float = 0.5
const PERPENDICULAR_FALL_THRESHOLD : float = 2.0
const AIR_BOUNCE_STRENGTH : float = 0.25

#global movement variables
var xform = null
var last_ground_pos : Vector3 = Vector3.ZERO
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
var ray_forward : Dictionary = {}
var ray_ground : Dictionary = {}
var ray_path : Dictionary = {}
var ray_down : Dictionary = {}
var on_wall : bool = false
var last_on_wall : bool = false

#global object references
@onready var Area : Area3D = get_node('Area3D')
@onready var Collision : CollisionShape3D = get_node('CollisionShape3D')
@onready var Camera_Pos: Node3D = $"../Camera_Pos"
@onready var Camera: Camera3D = $"../Camera_Pos/Camera3D"
@onready var Char_Ragdoll : CharacterRagdoll = $Char_Ragdoll
@onready var Char_Statemachine : CharacterStatemachine = $Char_Statemachine
@onready var Char_Tricks : CharacterTricks = $Char_Tricks
@onready var Char_Input : CharacterInput = $Char_Input 
@onready var Ingame_Ui : IngameOverlay = $Ingame_Ui
@onready var Char_Init : CharacterInit = $".."

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
	if Char_Init.is_playing:
		_init_player()
		_reset_player(Vector3(-3.149,6.868,18.256) + Vector3.UP * 5.0)
	else:
		Ingame_Ui.set_fail_view(false)
		Ingame_Ui.set_balance_view(false)
		
func _init_player():
	pass
	
func _physics_process(delta):
	if !Char_Init.is_playing:
		return
	Camera_Pos.global_position = Camera_Pos.position.lerp(global_position, delta * 10)
	if Char_Statemachine.is_player_state(Char_Statemachine.State.FALL):
		fall_timer -= delta
		if Char_Input.get_input().y and fall_timer < 0.1:
			_reset_player(last_ground_pos + Vector3.UP * 0.1)
	xform = global_transform
	_surface_check()
	Char_Statemachine.set_last_player_state()
	_player_state()
	_fall_check()
	match Char_Statemachine.player_state:
		Char_Statemachine.State.FALL:
			return
		Char_Statemachine.State.GROUND, Char_Statemachine.State.PIPE:
			_check_reverse_motion()
			_ground_movement(delta)
		Char_Statemachine.State.AIR:
			_air_movement(delta)
		Char_Statemachine.State.PIPESNAP:
			_check_bounce_path(true)
			_pipe_snap_movement(delta)
		Char_Statemachine.State.PIPESNAPAIR:
			_pipe_snap_air_movement(delta)
		Char_Statemachine.State.GRIND:
			_check_bounce_path(false)
			_grind_movement(delta)
		Char_Statemachine.State.LIP:
			_lip_movement(delta)
	global_transform = LibHelpers.align(global_transform, up_direction)
	last_up_dir = up_direction
	last_vel = velocity
	_set_up_direction()
	move_and_slide()
	if Char_Input.can_jump() and Char_Statemachine.is_player_state(Char_Statemachine.State.GROUND):
		apply_floor_snap()
		
func _player_state():
	if Char_Statemachine.is_player_state(Char_Statemachine.State.FALL):	#dont change the state if fallen
		return
	
	if Char_Statemachine.is_player_state(Char_Statemachine.State.GRIND) or Char_Statemachine.is_player_state(Char_Statemachine.State.LIP):
		Ingame_Ui.set_balance_view(true)
		if path == null:
			Char_Statemachine.set_player_state(Char_Statemachine.State.AIR)
			return
		if path_closed:
			return
		if !LibHelpers.get_stick_curve(path,  path_offset):
			velocity = xform.basis.z * path_vel * path_dir
			Char_Statemachine.set_player_state(Char_Statemachine.State.AIR)
			return
		return
	else:
		Ingame_Ui.set_balance_view(false)
		
	if Char_Statemachine.is_player_state(Char_Statemachine.State.PIPESNAP):
		if !LibHelpers.get_stick_curve(path,  path_offset) and !path_closed:
			Char_Statemachine.set_player_state(Char_Statemachine.State.PIPESNAPAIR)
			var newUpDir : Vector3 = Vector3.UP.cross(curve_tangent)
			if pipe_snap_flip:
				newUpDir*=-1
			if(newUpDir != Vector3.ZERO):
				up_direction = (newUpDir + last_up_dir)/2
			else:
				up_direction = last_up_dir
			return
	
	var _closest_path : Path3D = LibHelpers.get_closest_path(Area, position)	
	if _closest_path != null and !Char_Statemachine.is_player_state(Char_Statemachine.State.PIPESNAP):
		path = _closest_path
		path_closed = LibHelpers.is_path_closed(path)
		curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
		path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.25)
		path_offset = path.curve.get_closest_offset(position * path.global_transform)
		if Char_Input.get_input_tricks().x == 1 and !Char_Statemachine.is_player_state(Char_Statemachine.State.GRIND):
			var grind_start : Dictionary = LibHelpers.start_grind(position, velocity, path, path_offset)
			if grind_start.valid:
				_randomize_balance()
				path_vel = grind_start.vel
				path_dir = grind_start.dir
				curve_tangent = grind_start.tan
				Char_Statemachine.set_player_state(Char_Statemachine.State.GRIND)
				return
			if path_dir == 0:
				_randomize_balance()
				var lip_start : Dictionary = LibHelpers.start_lip(xform, position, velocity, path, path_offset)
				curve_tangent = lip_start.tan
				lip_start_dir = lip_start.dir
				lip_start_vel = lip_start.vel
				lip_start_up = lip_start.up
				Char_Statemachine.set_player_state(Char_Statemachine.State.LIP)
				return
	if !ray_ground:	#behavior while in air, or sticked to a pipe
		if Char_Statemachine.is_last_player_state(Char_Statemachine.State.PIPE) and Char_Input.get_input_tricks().z == 0 and Char_Input.get_input().y == 0:
			var _pipe_snap : Dictionary = LibHelpers.start_pipesnap(xform, position, velocity, last_up_dir, path, path_offset)
			if _pipe_snap.valid:
				curve_tangent = _pipe_snap.tan
				path_dir = _pipe_snap.dir
				path_vel = _pipe_snap.vel
				pipe_snap_flip = _pipe_snap.flip
				Char_Statemachine.set_player_state(Char_Statemachine.State.PIPESNAP)
				return			
		if !Char_Statemachine.is_player_state(Char_Statemachine.State.PIPESNAP) and !Char_Statemachine.is_player_state(Char_Statemachine.State.PIPESNAPAIR):
			Char_Statemachine.set_player_state(Char_Statemachine.State.AIR)
			return
	if Char_Statemachine.is_player_state(Char_Statemachine.State.AIR):
		if is_on_floor() and !Char_Statemachine.is_player_state(Char_Statemachine.State.GROUND):
			Char_Statemachine.set_player_state(Char_Statemachine.State.GROUND)
	if ray_ground:
		var _coll_info = ray_ground.collider
		if ray_ground.normal.dot(xform.basis.y) < 0.5:
			return
		if _coll_info.is_in_group('pipe') and !Char_Statemachine.is_player_state(Char_Statemachine.State.PIPE):
			Char_Statemachine.set_player_state(Char_Statemachine.State.PIPE)
			path = null
			return
		if _coll_info.is_in_group('floor') and !Char_Statemachine.is_player_state(Char_Statemachine.State.GROUND):
			Char_Statemachine.set_player_state(Char_Statemachine.State.GROUND)
			path = null
			return

func _surface_check():
	ray_ground = LibHelpers.raycast(position + xform.basis.y * 0.1, xform.basis.y, -0.5, self)
	ray_forward = LibHelpers.raycast(position + xform.basis.y * 0.25, xform.basis.z, 1.0, self)
	ray_path = LibHelpers.raycast(position + xform.basis.y * 1.0, curve_tangent * path_dir, -0.5, self)
	ray_down = LibHelpers.raycast(position + xform.basis.y * 0.25, Vector3.DOWN, 0.5, self)

func _set_up_direction():
	if ray_ground:	
		up_direction = ray_ground.normal
	else:
		up_direction = last_up_dir	

func _fall(_fall_reason, _fall_value):
	print(_fall_reason + ": " + str(_fall_value)+ "last velocity: " + str(last_vel.length()))
	Char_Ragdoll.set_start_simulation(last_vel)
	Char_Statemachine.set_player_state(Char_Statemachine.State.FALL)
	Ingame_Ui.set_fail_view(true)
	fall_timer = 2.0
	
func _reset_player(_pos):
	Ingame_Ui.set_fail_view(false)
	Ingame_Ui.set_balance_view(false)
	Char_Ragdoll.set_end_simulation()
	up_direction = Vector3.UP
	velocity = Vector3.ZERO
	last_vel = Vector3.ZERO
	global_position = _pos
	global_rotation =  Vector3(0,3.14/2,0)
	balance_angle = 0.0
	Char_Statemachine.reset_player_state()

func _ground_movement(delta): 	
	if Char_Statemachine.is_player_state(Char_Statemachine.State.GROUND) and path == null:
		last_ground_pos = global_position
	if Char_Input.get_input().y < 0:
		velocity *= 0.95
		global_rotate(xform.basis.y, Char_Input.get_input().x * ROT_KICKTURN * delta)
	else:
		global_rotate(xform.basis.y, Char_Input.get_input().x * ROT * delta)
	if Char_Input.get_input().y >= 0 and velocity.length() < MAX_VEL/8 and LibHelpers.forward_velocity(velocity, up_direction).length() > 0.1 or Char_Input.get_input().y > 0:
		velocity +=xform.basis.z * ACC * 0.25
	if (Char_Input.get_input().z > 0 and velocity.length() <= MAX_VEL and Char_Input.get_input().y != -1) or (Char_Input.get_input().z < 0 and velocity.length() >= -MAX_VEL):
		velocity += xform.basis.z * Char_Input.get_input().z * ACC
	if Char_Input.get_input_tricks().z > 0 and Char_Input.can_jump():
		velocity += Vector3.UP * JUMP_VEL
		Char_Input.set_jump_cooldown()
	velocity.y -= GRAVITY * delta
	_wall_bounce()
	velocity = LibHelpers.kill_orthogonal_velocity(xform, velocity)

func _air_movement(_delta): 	
	var _rot_delta = Char_Input.get_input().x * ROT_JUMP * _delta
	global_rotate(xform.basis.y, _rot_delta)
	velocity.y -= GRAVITY * _delta
	up_direction = lerp(up_direction,Vector3.UP, _delta * UP_ALIGN_SPEED)
	
func _pipe_snap_movement(delta): 
	global_rotate(xform.basis.y, Char_Input.get_input().x * ROT_JUMP * delta)
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

func _pipe_snap_air_movement(delta):	
	global_rotate(xform.basis.y, Char_Input.get_input().x * ROT_JUMP * delta)
	velocity.y -= GRAVITY * delta

func _grind_movement(delta) -> void: 	
	var _curve : Curve3D = path.curve
	curve_snap = _curve.sample_baked(path_offset, true)
	path_offset += path_vel * delta
	if path_closed:
		path_offset = LibHelpers.wrap_curve(path, path_offset)
	curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
	position = curve_snap
	up_direction =  _curve.sample_baked_up_vector(path_offset)
	var _target = global_position + curve_tangent * path_dir
	if _target != position:
		look_at(_target, up_direction)
	velocity = xform.basis.z * path_vel * path_dir
	if Char_Input.get_input_tricks().z and Char_Input.can_jump():
		velocity = xform.basis.z * abs(path_vel)
		velocity += xform.basis.y * Char_Input.get_input_tricks().z * JUMP_VEL
		velocity += xform.basis.x * balance_dir
		Char_Input.set_jump_cooldown()
		path = null
		return
	_balance_logic(delta, 0)
	
func _lip_movement(delta) -> void:
	var _curve : Curve3D = path.curve
	position = _curve.sample_baked(path_offset)
	up_direction = _curve.sample_baked_up_vector(path_offset)
	rotation.y = atan2(lip_start_dir.x,lip_start_dir.z)
	if(Char_Input.get_input_tricks().z) and Char_Input.can_jump():
		velocity = velocity.normalized() * -1
		Char_Statemachine.set_player_state(Char_Statemachine.State.AIR)
		position -= lip_start_dir * balance_dir * 0.5
		velocity = lip_start_vel.normalized() * -1
		up_direction = Vector3.UP
		rotation.y = atan2(lip_start_dir.x * -balance_dir,lip_start_dir.z * -balance_dir)
		Char_Input.set_jump_cooldown()
	_balance_logic(delta, 1)

func _randomize_balance() -> void:
	balance_time = 1.0
	balance_angle = 0.0
	var _rand : float  = randf()
	if (_rand >= 0.5):
		balance_dir = 1
	else:
		balance_dir = -1

func _balance_logic(delta: float, axis : int):
	if axis == 0:
		if(Char_Input.get_input().x != 0):
			_set_balance_dir(Char_Input.get_input().x)
	else:
		if(Char_Input.get_input().y != 0):
			_set_balance_dir(-Char_Input.get_input().y)
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
	if ray_path:
		print("hit!")
	if ray_path and !revert_path:
		if air:
			path_vel *= -AIR_BOUNCE_STRENGTH
		else: 
			path_vel *= -1.0
		path_dir *= -1
		revert_path = true
	if !ray_path:
		revert_path = false

func _fall_check() -> void:
	if Char_Statemachine.is_player_state(Char_Statemachine.State.FALL):
		return
	if global_position.y < - 100:
		_fall("out of bounds!", position)
	if Char_Statemachine.is_player_state(Char_Statemachine.State.GRIND) or Char_Statemachine.is_player_state(Char_Statemachine.State.LIP):
		if (balance_angle > PI /4 or balance_angle < -PI /4):
			_fall("balance issues", balance_angle)
			return
	if Char_Statemachine.is_last_player_state(Char_Statemachine.State.AIR) or Char_Statemachine.is_last_player_state(Char_Statemachine.State.PIPESNAPAIR):
		var _on_feet = LibHelpers.landed_on_feet(ray_down, up_direction, FLOOR_FALL_THRESHOLD)
		if !_on_feet.valid:
			_fall("faceplant", _on_feet.dot)
			return
	var _is_ground = Char_Statemachine.is_player_state(Char_Statemachine.State.GROUND) or Char_Statemachine.is_player_state(Char_Statemachine.State.PIPE)
	var _last_air = Char_Statemachine.is_last_player_state(Char_Statemachine.State.AIR) or Char_Statemachine.is_last_player_state(Char_Statemachine.State.PIPESNAP)
	if !_is_ground or !_last_air:
		return
	var _fwd_vel := LibHelpers.forward_velocity(velocity, up_direction)
	if _fwd_vel.length() <= PERPENDICULAR_FALL_THRESHOLD:
		return
	var _perp := LibHelpers.landed_perpendicular(_fwd_vel, xform.basis.z, FLOOR_FALL_THRESHOLD)
	if !_perp.valid:
		_fall("perpendicular", _perp.dot)

func _wall_bounce() -> void:
	if ray_forward and ray_forward.collider.is_in_group("wall"):
		on_wall = true
		if not last_on_wall:
			print("Wall hit!")
			var normal = ray_forward.normal      
	else:
		on_wall = false
	last_on_wall = on_wall
	pass
	#var _vel_length = LibHelpers.forward_velocity(velocity, up_direction).length()
	#if _vel_length < 1.0:
		#return
	#if get_slide_collision_count() > 0:
		#for i in range(get_slide_collision_count()):
			#var collision = get_slide_collision(i)
			#var collider = collision.get_collider()	
			#if collider and collider.is_in_group("wall"):
				#var normal = collision.get_normal()
				#velocity = xform.basis.z.bounce(normal) * _vel_length
				#position += normal * 0.1
				#print("Wall bounce! Normal: ", normal, " Velocity: ", velocity.length())
				#look_at(global_position - velocity.normalized())
				#on_wall = true
				#break  # Only handle first wall collision
				#
	#else:
		#on_wall = false
			
		
	
