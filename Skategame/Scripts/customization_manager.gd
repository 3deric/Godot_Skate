class_name CustomizationManager
extends Node

static var instance: CustomizationManager

signal color_updated(part: CustomizationPart.Part, sub: String, color: Color)
signal decal_updated(part: CustomizationPart.Part, index: int)
signal mesh_updated(part: CustomizationPart.Part, index: int)
signal float_updated(part: CustomizationPart.Part, sub: String, value: float)
signal customization_updated()

#var resources : Array[CustomizationAsset] = []
var resources : Dictionary = {}

var character_data : CharacterData

func _ready() -> void:
	instance = self
	_preload_customization_assets()
	character_data = CharacterData.new()


func reset_character() -> void:
	character_data = CharacterData.new()
	customization_updated.emit()


func update_color(part: CustomizationPart.Part,sub: String, color: Color ) -> void:
	match part:
		CustomizationPart.Part.BODY:
			match sub: 
				'eyes':
					character_data.eye_color = color
		CustomizationPart.Part.HAIR:
			match sub:
				'color':
					print("updating color")
					character_data.hair_color = color
		CustomizationPart.Part.TOP:
			match sub:
				'base':
					character_data.top_base_color = color
				'accent':
					character_data.top_accent_color = color
				'detail':
					character_data.top_detail_color = color
		CustomizationPart.Part.BOTTOM:
			match sub:
				'base':
					character_data.bottom_base_color = color
				'accent':
					character_data.bottom_accent_color = color
				'detail':
					character_data.bottom_detail_color = color
		CustomizationPart.Part.SHOES:
			match sub:
				'base':
					character_data.shoes_base_color = color
				'accent':
					character_data.shoes_accent_color = color
				'detail':
					character_data.shoes_detail_color = color
		CustomizationPart.Part.BOARD:
			match sub:
				'wheels':
					character_data.board_wheels_color = color
				'accent':
					character_data.board_accent_color = color
				'metal':
					character_data.board_metal_color= color

	color_updated.emit(part, sub, color)
	#customization_updated.emit()
	

func update_mesh(part: CustomizationPart.Part, index: int) -> void:
	match part:
		CustomizationPart.Part.HAIR:
			character_data.hair_mesh = index
		CustomizationPart.Part.TOP:
			character_data.top_mesh = index
		CustomizationPart.Part.BOTTOM:
			character_data.bottom_mesh = index
		CustomizationPart.Part.SHOES:
			character_data.shoes_mesh = index
		CustomizationPart.Part.HELMET:
			character_data.helmet_mesh = index
		CustomizationPart.Part.FACEWEAR:
			character_data.glasses_mesh
	mesh_updated.emit(part, index)
	#customization_updated.emit()
	

func update_decal(part: CustomizationPart.Part, index: int) -> void:
	match part:
		CustomizationPart.Part.TOP:
			character_data.top_decal = index
		CustomizationPart.Part.BOARD:
			character_data.board_decal = index
	decal_updated.emit(part, index)
	#customization_updated.emit()


func update_float(part: CustomizationPart.Part, sub : String ,value: float) -> void:
	match part:
		CustomizationPart.Part.BODY:
			match sub:
				'size':
					character_data.size = value
				'skin_color':
					character_data.skin_color = value
				'gender':
					character_data.gender = value
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
				print(resource.display_name)
		file_name = dir.get_next()
	dir.list_dir_end()
