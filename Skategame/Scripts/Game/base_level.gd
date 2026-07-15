class_name BaseLevel
extends Node3D

@export var _player_spawn : Marker3D
@export var _is_playing : bool = true

func get_player_spawn() -> Transform3D:
	return _player_spawn.global_transform
	
func get_is_playing() -> bool:
	return _is_playing
