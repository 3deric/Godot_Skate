class_name DebugView
extends Control

@onready var Character: CharacterController = $".."

func _process(_delta):
	queue_redraw()


func _draw():
	if Character.shape_col_ground:
		_debug_draw(Character.shape_col_ground[0].point,Character.shape_col_ground[0].point + Character.shape_col_ground[0].normal, Color.RED,2.0)
		_debug_draw(Character.global_position, Character.shape_col_ground[0].point, Color.YELLOW,2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.x, Color.GREEN, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.y, Color.RED, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.z, Color.BLUE ,2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.up_direction * 2, Color.PINK, 2.0)
	_debug_draw(Character.curve_snap, Character.curve_snap + Vector3.UP * 2, Color.PINK, 2.0)
	#_debug_draw(Character.global_position, Character.last_ground_pos, Color.BLUE, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.curve_tangent * Character.path_dir * -1, Color.BLUE, 2.0)
	
	#if Character.ray_forward != {}:
	#	_debug_draw(Character.ray_forward["position"], Character.ray_forward["position"] + Character.transform.basis.z.bounce(Character.ray_forward["normal"]), Color.BLUE, 2.0)
	#	_debug_draw(Character.global_position + Character.transform.basis.y * 1.0, Character.ray_forward["position"], Color.RED, 2.0)
	#else:
	#	_debug_draw(Character.global_position + Character.transform.basis.y * 1.0, Character.global_position + Character.transform.basis.y * 1.0 + Character.transform.basis.z * 1.0, Color.RED, 2.0)
	
func _debug_draw(from, to, col, thickness):
	if Character.Camera == null:
		return
	draw_line(Character.Camera.unproject_position(from), Character.Camera.unproject_position(to), col, thickness)
