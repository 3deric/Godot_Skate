class_name CharacterAnimation
extends Node3D

#controls the animtree of the Char_Controller
@onready var anim_tree: AnimationTree = %AnimationTree
@onready var Char_Controller: CharacterController = $".."
@onready var Char : Node3D = %Char
@onready var skeleton_3d: Skeleton3D = %Char_Skeleton/Skeleton3D
@onready var body_mesh : MeshInstance3D = $"../Char/Char_Skeleton/Skeleton3D/char_body"
@onready var Char_Statemachine: CharacterStatemachine = $"../Char_Statemachine"
@onready var Char_Input : CharacterInput = $"../Char_Input" 
@onready var Char_Init : CharacterInit = $"../.."

var anim_blend : Vector2 = Vector2.ZERO #blendvector for animations
var ANIM_INTERP_SPEED : float = 5.0 #interpolation speed between anim states
var INTERP_SPEED : float = 15.0 #interpolation speed of the visual character

var trick_anim : bool = false #false if first trick animation is used, true if second
var trick0 : AnimationNode
var trick1 : AnimationNode


func _ready() -> void:
	skeleton_3d.show_rest_only = false
	#body_mesh.set_blend_shape_value(1,0.3)
	#body_mesh.set_blend_shape_value(2,0)
	trick0 = anim_tree.tree_root.get_node("Trick0")
	trick1 = anim_tree.tree_root.get_node("Trick1")
	if !Char_Init.is_playing:
		anim_tree.set('parameters/conditions/is_setup', true)
	else:
		Char.top_level = true

func _process(delta: float) -> void:
	_animation_handler(delta)
	_set_vis_balance()
	_lerp_vis_transform(delta, INTERP_SPEED)

func _set_vis_balance() -> void:
	if Char_Statemachine.is_player_state(CharStates.State.GRIND):
		Char.rotation.z = -Char_Controller.balance_angle * 0.5
		return
	if Char_Statemachine.is_player_state(CharStates.State.LIP):
		Char.rotation.x = -Char_Controller.balance_angle * 0.5	
	
func _lerp_vis_transform(_delta, _speed) -> void:
	Char.global_transform = Char.global_transform.interpolate_with(Char_Controller.global_transform, _delta * _speed)
	if !Char_Statemachine.is_player_state(CharStates.State.GRIND):
		Char.global_position = Char_Controller.global_position

func reset_vis_transform() -> void:
	Char.global_transform = Char_Controller.global_transform

func _animation_handler(delta) -> void:
	anim_blend = anim_blend.lerp(Vector2(Char_Input.get_input().x, Char_Input.get_input().y), delta * ANIM_INTERP_SPEED)
	match Char_Statemachine.player_state:
		CharStates.State.FALL:
			anim_tree.set('parameters/conditions/is_riding', false)
			anim_tree.set('parameters/conditions/is_stopped', true)
			anim_tree.set('parameters/conditions/is_trick0', false)
			anim_tree.set('parameters/conditions/is_trick1', false)	
		CharStates.State.GROUND, CharStates.State.PIPE:	
			if Char_Controller.velocity.length() > 0.05:
				anim_tree.set('parameters/conditions/is_riding', true)
				anim_tree.set('parameters/conditions/is_stopped', false)
			else:
				anim_tree.set('parameters/conditions/is_riding', false)
				anim_tree.set('parameters/conditions/is_stopped', true)
			anim_tree.set('parameters/conditions/is_trick0', false)
			anim_tree.set('parameters/conditions/is_trick1', false)
			anim_tree.set('parameters/Ground/blend_position', anim_blend)
		CharStates.State.AIR, CharStates.State.PIPESNAP, CharStates.State.PIPESNAPAIR:
			anim_tree.set('parameters/conditions/is_riding', false)
			anim_tree.set('parameters/conditions/is_stopped', false)
			anim_tree.set('parameters/Air/blend_position', anim_blend)
		CharStates.State.GRIND:
			anim_tree.set('parameters/conditions/is_riding', false)
			anim_tree.set('parameters/conditions/is_stopped', false)
			anim_tree.set('parameters/Grind/blend_position', anim_blend)
		CharStates.State.LIP:
			anim_tree.set('parameters/conditions/is_riding', false)
			anim_tree.set('parameters/conditions/is_stopped', false)
			anim_tree.set('parameters/Lip/blend_position', anim_blend)

func set_trick_animation(animation: String) -> void:
	anim_tree.set('parameters/conditions/is_riding', false)
	anim_tree.set('parameters/conditions/is_stopped', false)
	if !trick_anim:
		trick_anim = true
		trick0.animation = animation
		anim_tree.set('parameters/conditions/is_trick0',true)
		anim_tree.set('parameters/conditions/is_trick1',false)
	else:
		trick_anim = false
		trick1.animation = animation
		anim_tree.set('parameters/conditions/is_trick0',false)
		anim_tree.set('parameters/conditions/is_trick1',true)
