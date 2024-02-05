@tool
@static_unload
extends Node2D

const SprinkleSettingsDock = preload("../dock.gd")

var key := ""

@onready var gpu_particle_2d: GPUParticles2D = $GPUParticles2D


func _ready():
	if SprinkleSettingsDock.sound:
		$AudioStreamPlayer.play()
	
	gpu_particle_2d.emitting = true
	if SprinkleSettingsDock.chars and key:
		var label: Label = $Label
		label.text = key
		label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))
		$AnimationPlayer.play("default")


func _on_Timer_timeout():
	if get_tree().edited_scene_root != self:
		queue_free()
