class_name BaseLevel
extends Node3D

@onready var player_spawn: Node3D = $Player_Spawn

func get_player_spawn() -> Transform3D:
	return player_spawn.global_transform
