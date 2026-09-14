class_name CustomizationManager
extends Node

static var instance: CustomizationManager

signal color_updated(part: CustomizationPart.Part, sub: String, color: Color)
signal decal_updated(part: CustomizationPart.Part, index: int)
signal mesh_updated(part: CustomizationPart.Part, index: int)
signal float_updated(part: CustomizationPart.Part, sub: String, value: float)
signal customization_updated()

const SAVE_PATH = "user://character_data.json"
#var resources : Array[CustomizationAsset] = []
var resources : Dictionary = {}

var character_data : CharacterData

func _ready() -> void:
	instance = self
	_preload_customization_assets()
	character_data = CharacterData.new()
	#character_data = _load_chararacter_data()
	_save_character_data(character_data)
	
func _save_character_data(char_data : CharacterData) -> void:
	var file : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_dict = {}
	save_dict["game_version"] = ProjectSettings.get_setting("application/config/version") 
	save_dict["char_name"] = char_data.char_name
	save_dict["customization_data"] = char_data.customization_data
	file.store_string(JSON.stringify(save_dict))
	file.close()
	
func _load_chararacter_data() -> CharacterData:
	var data = CharacterData.new()
	if not FileAccess.file_exists(SAVE_PATH):
		return data
	var file : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text : String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed["game_version"] != ProjectSettings.get_setting("application/config/version"):
		return data
	data.char_name = parsed["char_name"]
	data.customization_data = parsed["customization_data"]
	return data

func reset_character() -> void:
	character_data = CharacterData.new()
	customization_updated.emit()


func update_color(part: CustomizationPart.Part,sub: String, color: Color ) -> void:
	character_data.customization_data[part][sub] = color
	color_updated.emit(part, sub, color)
	#customization_updated.emit()
	

func update_mesh(part: CustomizationPart.Part, index: int) -> void:
	character_data.customization_data[part]["mesh"] = index
	mesh_updated.emit(part, index)
	#customization_updated.emit()
	

func update_decal(part: CustomizationPart.Part, decal_part : CustomizationPart.Part, index: int) -> void:
	character_data.customization_data[part]["decal"] = index
	decal_updated.emit(part, decal_part, index)
	#customization_updated.emit()


func update_float(part: CustomizationPart.Part, sub : String ,value: float) -> void:
	character_data.customization_data[part][sub] = value
	float_updated.emit(part, sub, value)
	#customization_updated.emit()
		
func _preload_customization_assets() -> void:
	var dir = DirAccess.open("res://Assets/Characters/Customization")
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource : CustomizationAsset = load("res://Assets/Characters/Customization/" + file_name) as CustomizationAsset
			if resource:
				if not resources.has(resource.part):
					resources[resource.part] = []
				resources[resource.part].append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	for key in resources:
		resources[key].sort_custom(func(a, b):
			return a.resource_path.get_file().to_lower() < b.resource_path.get_file().to_lower()
)
