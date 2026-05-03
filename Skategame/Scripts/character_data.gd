class_name CharacterData 
extends Resource

enum CharacterPart {Body, Hair, Top, Bottom, Shoes, Board}
enum BoardDecal {Bare = 0, Style1 = 1, Style2 = 2}
enum TopDecal {Bare = 0, Style1 = 1, Style2 = 2, Style3 = 3, Style4 = 4}
enum HairMesh {Bald = 0, Style1 = 1, Style2 = 2}
enum TopMesh {Nothing = 0, Shirt = 1, Hoodie = 2}
enum BottomMesh {Nothing = 0, Shorts = 1, Jeans = 2}
enum ShoesMesh {Nothing = 0, Sneakers = 1, FlatShoes = 2, Boots = 3, Flipflops =4}

@export var top_base_color: Color = Color("5d7937")
@export var top_accent_color: Color = Color("5d7937")
@export var top_detail_color: Color = Color("adaca0")
@export var bottom_base_color: Color = Color("826a4a")
@export var bottom_accent_color: Color = Color("b7b7b7")
@export var bottom_detail_color: Color = Color("e9a174")
@export var shoes_base_color: Color = Color("323232")
@export var shoes_accent_color: Color = Color("8e7247")
@export var shoes_detail_color: Color = Color("9e9e9e")
@export var board_wheels_color: Color = Color(0.758,0.721,0.471,1.0)
@export var board_accent_color: Color = Color(0.354,0.95,0.45,1.0)
@export var board_metal_color: Color = Color(0.8,0.8,0.8,1.0)
@export var hair_color : Color = Color(0.555,0.465,0.351,1.0)
@export var skin_color : float = 0.25
@export var eye_color : Color = Color(0.356,0.425,0.583,1.0)
@export var size : float = 1.0
@export var board_decal : int = 1
@export var top_decal : int = 0
@export var hair_mesh : int = 1
@export var top_mesh : int = 1
@export var bottom_mesh : int = 1
@export var shoes_mesh : int = 1
@export var gender : float = 0
