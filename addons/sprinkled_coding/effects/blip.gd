@tool
@static_unload
extends Node2D

const SprinkleSettings = preload("../dock.gd")

var key := ""
var pitch_increase := 0.0


func _ready():
	if SprinkleSettings.sound:
		$AudioStreamPlayer.pitch_scale += pitch_increase
		$AudioStreamPlayer.play()
	
	if SprinkleSettings.blips:
		$GPUParticles2D.emitting = true
	
	if SprinkleSettings.chars and key:
		var label: Label = $Label
		label.text = key
		label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))
		$AnimationPlayer.play("default")


func _on_Timer_timeout():
	if get_tree().edited_scene_root != self:
		queue_free()
