class_name BaseLevel
extends Node3D

@export var _player_spawn : Marker3D
@export var _is_playing : bool = true

func get_player_spawn() -> Transform3D:
	if _player_spawn != null:
		return _player_spawn.global_transform
	return global_transform
	
func get_is_playing() -> bool:
	return _is_playing
