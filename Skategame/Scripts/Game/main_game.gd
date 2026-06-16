class_name MainGame
extends Node
# main entry point for the game
# based on https://www.youtube.com/watch?v=V4SO7foDoW4&list=WL&index=1

# player and level resources
const PLAYER_CHARACTER : 	String = "uid://d2nejhxrsjjgk"
const LEVEL_MENU : 			String = "uid://4dexi0qui2ct"
const LEVEL_1 : 			String = "uid://bxeywehmeblyi"

var player : CharacterController = null
#var _current_level : BaseLevel = null

# Game world root nodes
@onready var level_root: Node3D = $World/LevelRoot
@onready var entity_root: Node3D = $World/EntityRoot
@onready var effect_root: Node3D = $World/EffectRoot

# UI Root nodes
@onready var hud_root: Control = $HudLayer/HudRoot
@onready var pause_root: Control = $PauseLayer/PauseRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugLayer/DebugRoot


func _init_player() -> void:
	pass
