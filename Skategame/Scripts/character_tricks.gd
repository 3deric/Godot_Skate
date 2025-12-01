class_name CharacterTricks
extends Node3D

enum Tricks {
		OLLI, 
		MANUAL,
		GRIND,
		KICKFLIP,
		HEELFLIP
	}

var tricks : Dictionary = {}

	
func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	pass
		
		
func set_start_trick() -> void:
	pass
	
	
func set_end_trick() -> void:
	pass
	

func end_combo() -> void:
	tricks = {}
