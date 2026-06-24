class_name MainGame
extends Node
# main entry point for the game
# based on https://www.youtube.com/watch?v=V4SO7foDoW4&list=WL&index=1

# player and level resources
const PLAYER_SCENE_UID : 	String = "uid://d2nejhxrsjjgk"
const LEVEL_MENU_UID : 		String = "uid://4dexi0qui2ct"
const LEVEL_1_UID : 		String = "uid://bxeywehmeblyi"
const LEVEL_2_UID : 		String = "uid://duaw5sk1sesed"

var player : Player = null
var _current_level : BaseLevel = null

# Game world root nodes
@onready var level_root: Node3D = $World/LevelRoot
@onready var entity_root: Node3D = $World/EntityRoot
@onready var effect_root: Node3D = $World/EffectRoot

# UI Root nodes
@onready var hud_root: Control = $HudLayer/HudRoot
@onready var pause_root: Control = $PauseLayer/PauseRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugLayer/DebugRoot

func _ready() -> void:
	_init_player()
	load_level(LEVEL_2_UID)

func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend Player or DNE: " + PLAYER_SCENE_UID)
		return
		
	entity_root.add_child(player)
		
func load_level(level_scene : String) -> void:
	_deferred_load_level(level_scene)
	
func _deferred_load_level(level_scene_uid : String) -> void:
	if _current_level != null:
		_current_level.queue_free()
		_current_level = null
		
	# Allow the old level to finish freeing befor adding a new one
	await get_tree().process_frame
	
	var new_level_packed : PackedScene =\
		ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as packed scene: " + level_scene_uid)
		return
	
	_current_level = new_level_packed.instantiate() as BaseLevel
	if _current_level == null:
		push_error("Loaded level scene does not extend BaseLevel or DNE: " + level_scene_uid)
		return
	
	level_root.add_child(_current_level)
	
	await get_tree().process_frame
	_place_player_at_level_spawn()
	#_setup_level_camera()

func _place_player_at_level_spawn() -> void:
	player.init(_current_level.get_player_spawn())
