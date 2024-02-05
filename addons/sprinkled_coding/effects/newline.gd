@tool
@static_unload
extends Node2D

const SprinkleSettingsDock = preload("../dock.gd")

func _ready():
	if SprinkleSettingsDock.blips:
		$GPUParticles2D.emitting = true


func _on_Timer_timeout():
	if get_tree().edited_scene_root != self:
		queue_free()
