class_name CharacterAnimation
extends Node3D

#controls the animtree of the Char_Controller
@onready var anim_tree: AnimationTree = %AnimationTree
@onready var Char : Node3D = %Char
@onready var skeleton_3d: Skeleton3D = %Char_Skeleton/Skeleton3D
@onready var body_mesh : MeshInstance3D = $"../Char/Char_Skeleton/Skeleton3D/char_body"

var anim_blend : Vector2 = Vector2.ZERO #blendvector for animations
var ANIM_INTERP_SPEED : float = 5.0 #interpolation speed between anim states

var trick_anim : bool = false #false if first trick animation is used, true if second
var trick0 : AnimationNode
var trick1 : AnimationNode


func init(is_playing : bool) -> void:
	reset()
	skeleton_3d.show_rest_only = false
	#var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
	#playback.start("Start")
	body_mesh.set_blend_shape_value(2,0.3) # smile
	body_mesh.set_blend_shape_value(3,0) # blink
	trick0 = anim_tree.tree_root.get_node("Trick0")
	trick1 = anim_tree.tree_root.get_node("Trick1")
	if !is_playing:
		anim_tree.set('parameters/conditions/is_setup', true)
		
func reset():
	anim_tree.set('parameters/conditions/is_setup', false)
	anim_tree.set('parameters/conditions/is_riding', false)
	anim_tree.set('parameters/conditions/is_stopped', false)
	anim_tree.set('parameters/conditions/is_trick0', false)
	anim_tree.set('parameters/conditions/is_trick1', false)	

func set_vis_balance(state : CharStates.State, balance_angle : float) -> void:
	if state == CharStates.State.GRIND:
		var current_rotation  = skeleton_3d.rotation
		skeleton_3d.rotation = Vector3(current_rotation.x, current_rotation.y, -balance_angle * 0.5)
	elif state == CharStates.State.LIP:
		var current_rotation = skeleton_3d.rotation
		skeleton_3d.rotation = Vector3(-balance_angle * 0.5, current_rotation.y, current_rotation.z)
	else:
		skeleton_3d.rotation = Vector3(0,0,0)
		
func set_vis_transform(char_controller : CharacterController, _delta, _speed) -> void:
	Char.global_transform = Char.global_transform.interpolate_with(char_controller.global_transform, _delta * _speed)
	Char.global_position = char_controller.global_position

func reset_vis_transform(char_controller : CharacterController) -> void:
	Char.global_transform = char_controller.global_transform

func animation_handler(char_controller: CharacterController, input : Vector3, state : CharStates.State, delta) -> void:
	anim_blend = anim_blend.lerp(Vector2(input.x, input.y), delta * ANIM_INTERP_SPEED)
	match state:
		CharStates.State.FALL:
			anim_tree.set('parameters/conditions/is_riding', false)
			anim_tree.set('parameters/conditions/is_stopped', true)
			anim_tree.set('parameters/conditions/is_trick0', false)
			anim_tree.set('parameters/conditions/is_trick1', false)	
		CharStates.State.GROUND, CharStates.State.PIPE:	
			if char_controller.velocity.length() > 0.05:
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
