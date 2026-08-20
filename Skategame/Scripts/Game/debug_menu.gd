class_name  DebugMenu 
extends Control

@onready var label_fps: Label = $MarginContainer/VBoxContainer/LabelFPS
@onready var label_version: Label = $MarginContainer/VBoxContainer/LabelVersion
@onready var label_project: Label = $MarginContainer/VBoxContainer/LabelProject


func init() -> void:
	label_version.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	label_project.text = "Project: " + ProjectSettings.get_setting("application/config/name")

func _process(delta: float) -> void:
	label_fps.text = "FPS: " + str(int(Engine.get_frames_per_second()))
