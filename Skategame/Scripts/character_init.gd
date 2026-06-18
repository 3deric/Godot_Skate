class_name Player
extends Node3D

@export var is_playing : bool = false
var start_position : Vector3 = Vector3.ZERO
var start_rotation : Vector3 = Vector3.ZERO
@onready var Char_Controller : CharacterController = $Character


func _ready() -> void:
	start_position = global_position
	start_rotation = global_rotation
	Char_Controller.init_player()

func get_is_playing() -> bool:
	return is_playing
	
func get_start_position() -> Vector3:
	return start_position
	
func get_start_rotation() -> Vector3:
	return start_rotation
