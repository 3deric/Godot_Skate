class_name Player
extends Node3D

@export var is_playing : bool = false
var start_transform : Transform3D
@onready var Char_Controller : CharacterController = $Character

func set_is_playing(playing : bool) -> void:
	is_playing = playing

func get_is_playing() -> bool:
	return is_playing
	
func get_start_transform() -> Transform3D:
	return start_transform
	
func init() -> void:
	Char_Controller.init_player()

func init_level(_transform : Transform3D, _is_playing : bool) -> void:
	start_transform = _transform
	is_playing = _is_playing
	Char_Controller.set_start_transform(_transform)
