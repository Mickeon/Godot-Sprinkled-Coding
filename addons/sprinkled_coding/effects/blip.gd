@tool
extends Node2D

const SprinkleSettingsDock = preload("../dock.gd")

var key := ""
var pitch_increase := 0.0


func _ready():
	if SprinkleSettingsDock.sound:
		$AudioStreamPlayer.pitch_scale += pitch_increase
		$AudioStreamPlayer.play()
	
	if SprinkleSettingsDock.blips:
		$GPUParticles2D.emitting = true
	
	if SprinkleSettingsDock.chars and key:
		var label: Label = $Label
		label.text = key
		label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))
		$AnimationPlayer.play("default")


func _on_Timer_timeout():
	if get_tree().edited_scene_root != self:
		queue_free()
