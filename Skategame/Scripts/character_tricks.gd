class_name CharacterTricks
extends Node3D

enum Tricks {
		OLLI, 
		MANUAL,
		GRIND,
		KICKFLIP,
		HEELFLIP
	}

var rot : float = 0.0

var tricks : Dictionary = {}

	
func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	pass
		
		
func set_start_trick() -> void:
	pass
	
	
func set_end_trick() -> void:
	print("Rotated " + str(rot) )
	_reset_air_rot()


func set_air_rot(_delta : float) -> void:
	rot = rot + _delta
	
func _reset_air_rot() -> void:
	rot = 0.0
	
func end_combo() -> void:
	tricks = {}
