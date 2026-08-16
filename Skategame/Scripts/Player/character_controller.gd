class_name CharacterController
extends CharacterBody3D

#player settings
@export var stats : PlayerSettings

#global movement variables
var xform = null
var last_ground_transform : Transform3D
var fall_timer : float = 0.0
var last_up_dir : Vector3 = Vector3.UP
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
var standing_timer : float = GlobalSettings.STANDING_TIMER

#global object references
@onready var Area : Area3D = get_node('Area3D')
@onready var Collision : CollisionShape3D = get_node('CollisionShape3D')
@onready var Shape_Cast : ShapeCast3D = $ShapeCast3D
@onready var Shape_Cast_Ground : ShapeCast3D = $ShapeCast3DGround
@onready var Camera_Pos: Node3D = $"../Character_Camera/Camera_Pos"
@onready var Camera: Camera3D = $"../Character_Camera/Camera_Pos/Camera3D"
@onready var Char_Ragdoll : CharacterRagdoll = $"../Systems/Char_Ragdoll"
@onready var Char_Animation: CharacterAnimation = $"../Systems/Char_Animation"
@onready var Char_Tricks : CharacterTricks = $"../Systems/Char_Tricks"
@onready var Char_Input : CharacterInput = $"../Systems/Char_Input"
@onready var Char_Fall : CharacterFallcheck = $"../Systems/Char_Fall"
@onready var Char_Statemachine: CharacterStatemachine = $"../Systems/Char_Statemachine"
@onready var Player_Scene : Player = $".."

#grind and lip trick variables
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

func init_player(_transform : Transform3D, _is_playing : bool):
	Char_Statemachine.init()

func _process(delta: float) -> void:
	Char_Statemachine.process(delta)
	Char_Animation.set_vis_transform(self, delta, GlobalSettings.INTERP_SPEED)

func _physics_process(delta):
	Camera_Pos.global_position = Camera_Pos.position.lerp(global_position, delta * 10)
	xform = global_transform
	Char_Statemachine.physics_process(delta)

func surface_check(is_air : bool = true, is_grind : bool = false) -> void:
	var _speed : float = velocity.length()
	var _basis_y : Vector3 = xform.basis.y
	var _forward_dir : Vector3 = Vector3.ZERO
	var _move_clamp : float = min(_speed, 0.5)
	
	if is_grind:
		_forward_dir = curve_tangent * -path_dir * _move_clamp
	else:
		_forward_dir = LibHelpers.horizontal_velocity(velocity).normalized() * _move_clamp

	if Char_Input.can_jump():
		var ray_dist : float = (GlobalSettings.RAY_GROUND_DIST if (is_air) else GlobalSettings.RAY_GROUND_AIR_DIST)
		if is_grind:
			Shape_Cast_Ground.target_position = to_local(position -basis.y * ray_dist + basis.z * 2.0)
		else:
			Shape_Cast_Ground.target_position = to_local(position -basis.y * ray_dist)
		shape_col_ground = Shape_Cast_Ground.collision_result
		if shape_col_ground:
			var _col_normal = shape_col_ground[0].normal
			var _dot = _col_normal.dot(up_direction)
			if shape_col_ground[0].collider.is_in_group("wall") or _dot < GlobalSettings.SHAPE_COL_DOT:
				shape_col_ground = []
	else:
		shape_col_ground = []
	Shape_Cast.target_position = to_local(position + _forward_dir * GlobalSettings.SHAPE_CAST_OFFSET_MULTIPLIER)
	shape_col_fwd = Shape_Cast.collision_result

func set_char_up_direction() -> void:
	if shape_col_ground:
		if !shape_col_ground[0].collider.is_in_group("wall"):
			up_direction = shape_col_ground[0].normal
	else:
		up_direction = last_up_dir

func set_fall() -> void:
	Char_Tricks.set_clear_tricks()
	Char_Ragdoll.set_start_simulation(last_vel)
	fall_timer = GlobalSettings.FALL_TIMER
	
func _reset_player(_transform : Transform3D) -> void:
	Char_Ragdoll.set_end_simulation()
	Char_Animation.reset_vis_transform(self)
	standing_timer = GlobalSettings.STANDING_TIMER
	up_direction = Vector3.UP
	velocity = Vector3.ZERO
	last_vel = Vector3.ZERO
	global_transform = _transform
	Camera_Pos.global_position = _transform.origin
	balance_angle = 0.0
	Char_Input.reset()

func randomize_balance() -> void:
	balance_time = 1.0
	balance_angle = 0.0
	var _rand : float  = randf()
	balance_dir = 1 if _rand >= 0.5 else -1

func balance_logic(delta: float, axis : int) -> void:
	if axis == 0:
		if(Char_Input.get_input().x > 0.6 or Char_Input.get_input().x < -0.6):
			_set_balance_dir(round(Char_Input.get_input().x))
	else:
		if(Char_Input.get_input().y > 0.6 or Char_Input.get_input().y < - 0.6):
			_set_balance_dir(round(-Char_Input.get_input().y))
	balance_time += GlobalSettings.BALANCE_TIME_INC * delta
	balance_angle += GlobalSettings.BALANCE_MULTI * delta * balance_dir * balance_time
	
func _set_balance_dir(_dir: int) -> void:
	balance_dir = _dir
	
func reset_shapecast(enabled : bool) -> void:
	Shape_Cast_Ground.collide_with_bodies = enabled
	
func set_path() -> void:
	var _closest_path : Path3D = LibHelpers.get_closest_path(Area, position)
	if _closest_path != null:
		if path != _closest_path:
			print(_closest_path)
		path = _closest_path
		path_closed = LibHelpers.is_path_closed(path)
		path_offset = path.curve.get_closest_offset(position * path.global_transform)
		curve_tangent = LibHelpers.get_path_tangent(path, path_offset)
		path_dir = LibHelpers.get_path_dir(curve_tangent, velocity, 0.25)
	else:
		path = null

func get_pipesnap(_jump : bool = false) -> Dictionary: # Todo, refactor 
	if path == null:
		return {"valid": false}
	if global_position.y > LibHelpers.get_path_position(path, path_offset).y or _jump:
		var _pipe_snap : Dictionary = LibHelpers.start_pipesnap(xform, velocity, path, path_offset)
		var _stick = LibHelpers.get_stick_curve(path, path_offset, 1.0)
		if path_closed: #always set stick to true when the path is closed
			_stick = true
		if _pipe_snap.valid  and xform.basis.z.dot(Vector3.UP) >= 0.1 and _stick:
			curve_tangent = _pipe_snap.tan
			path_dir = _pipe_snap.dir
			path_vel = _pipe_snap.vel
			pipe_snap_flip = _pipe_snap.flip
			shape_col_ground = []
			if _jump:
				return {"valid": true,"air": false}
			if Char_Input.get_input().y != 0:
				return {"valid": true,"air": true}
			return {"valid": true,"air": false}
	return {"valid": false}	
	
func get_can_grind() -> bool:
	if !path:
		return false
	var _grind_start : Dictionary = LibHelpers.start_grind(velocity, path, path_offset)
	if _grind_start.valid:
		path_vel = _grind_start.vel
		curve_tangent = _grind_start.tan
		path_dir = _grind_start.dir
		return true
	return false
	
func get_can_lip() -> bool:
	if !path:
		return false
	var _lip_start : Dictionary = LibHelpers.start_lip(xform, velocity, path, path_offset)
	if _lip_start: # _lip_start.valid dont check if its valid since grind check has to return false before
		var _curve = path.curve
		lip_start_pos = _lip_start.pos
		curve_tangent = _lip_start.tan
		lip_start_dir = _lip_start.dir
		lip_start_vel = _lip_start.vel
		lip_start_up = _lip_start.up
		return true
	return false

func handle_bounce() -> void:
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

func handle_wall_bounce() -> void:
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
			print('Wall bounce! Normal: ', _normal, ' Velocity: ', velocity.length())

func set_previous_values() -> void:
	last_up_dir = up_direction
	last_vel = velocity

func set_up_alignment() -> void:
	self.global_transform = LibHelpers.align(self.global_transform, self.up_direction)

func set_path_null() -> void:
	self.path = null
