class_name CharacterRBDCollision
extends Node

@onready var area_3drbd: Area3D = $"../../Character/Area3DRBD"
@onready var Ctrl : CharacterController = $"../../Character"

# area collision layer: 9, collision mask: 9
# rbd collision layer 9, collision mask 1,9
func _physics_process(delta: float) -> void:
	_rbd_collision()
	
func _rbd_collision() -> void:
	for body in area_3drbd.get_overlapping_bodies():
		if body is RigidBody3D:
			var push_dir = body.global_position -  Ctrl.global_position
			var impulse = push_dir * Ctrl.velocity.length()
			body.apply_central_impulse(impulse)
