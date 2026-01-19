class_name DebugView
extends Control

@onready var Character: CharacterBody3D = $".."
@onready var Char_Statemachine: Node3D = $"../Char_Statemachine"

func _process(_delta):
	queue_redraw()


func _draw():
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.x, Color.GREEN, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.y, Color.RED, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.transform.basis.z, Color.BLUE ,2.0)
	if Char_Statemachine.is_player_state(CharStates.State.GRIND):
		_debug_draw(Character.global_position, Character.global_position + Character.xform.basis.z * Character.path_vel * 0.25, Color.PURPLE, 4.0)
	else:	
		_debug_draw(Character.global_position, Character.global_position + Character.velocity * 0.25, Color.PURPLE, 4.0)		
	_debug_draw(Character.global_position, Character.global_position + Character.up_direction * 2, Color.PINK, 2.0)
	_debug_draw(Character.curve_snap, Character.curve_snap + Vector3.UP * 2, Color.PINK, 2.0)
	_debug_draw(Character.global_position, Character.last_ground_pos, Color.BLUE, 2.0)
	_debug_draw(Character.global_position, Character.global_position + Character.curve_tangent * Character.path_dir * -1, Color.BLUE, 2.0)
	
	if Character.ray_forward != {}:
		_debug_draw(Character.ray_forward["position"], Character.ray_forward["position"] + Character.transform.basis.z.bounce(Character.ray_forward["normal"]), Color.BLUE, 2.0)
		_debug_draw(Character.global_position + Character.transform.basis.y * 1.0, Character.ray_forward["position"], Color.RED, 2.0)
	else:
		_debug_draw(Character.global_position + Character.transform.basis.y * 1.0, Character.global_position + Character.transform.basis.y * 1.0 + Character.transform.basis.z * 1.0, Color.RED, 2.0)
	
func _debug_draw(from, to, col, thickness):
	if Character.Camera == null:
		return
	draw_line(Character.Camera.unproject_position(from), Character.Camera.unproject_position(to), col, thickness)
