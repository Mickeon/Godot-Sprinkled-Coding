@tool
@static_unload
extends Node2D

const SprinkleSettings = preload("../dock.gd")

func _ready():
	if SprinkleSettings.blips:
		$GPUParticles2D.emitting = true


func _on_Timer_timeout():
	if get_tree().edited_scene_root != self:
		queue_free()
