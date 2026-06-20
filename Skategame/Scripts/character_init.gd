class_name Player
extends Node3D

@export var is_playing : bool = false
var start_transform : Transform3D
@onready var Char_Controller : CharacterController = $Character

func get_is_playing() -> bool:
	return is_playing
	
func get_start_transform() -> Transform3D:
	return start_transform
	
func init(_transform : Transform3D) -> void:
	start_transform = _transform
	Char_Controller.init_player(start_transform)
