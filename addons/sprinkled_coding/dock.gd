@tool
@static_unload
extends Control

const BASE_XP := 50
const CONFIG_PATH := "user://sprinkled_coding.cfg"

static var explosions := true
static var blips := true
static var chars := true
static var shake := true
static var sound := true
static var fireworks := true

var xp := 0
var xp_next := 2 * BASE_XP
var level := 1
var cfg := ConfigFile.new()

@onready var explosion_checkbox: CheckButton = $VBoxContainer/GridContainer/explosionCheckbox
@onready var blip_checkbox: CheckButton = $VBoxContainer/GridContainer/blipCheckbox
@onready var chars_checkbox: CheckButton = $VBoxContainer/GridContainer/charsCheckbox
@onready var shake_checkbox: CheckButton = $VBoxContainer/GridContainer/shakeCheckbox
@onready var sound_checkbox: CheckButton = $VBoxContainer/GridContainer/soundCheckbox
@onready var fireworks_checkbox: CheckButton = $VBoxContainer/GridContainer/fireworksCheckbox

@onready var progress: TextureProgressBar = $VBoxContainer/XP/ProgressBar
@onready var sfx_fireworks: AudioStreamPlayer = $VBoxContainer/XP/ProgressBar/sfxFireworks
@onready var fireworks_timer: Timer = $VBoxContainer/XP/ProgressBar/fireworksTimer
@onready var fire_particles_one: GPUParticles2D = $VBoxContainer/XP/ProgressBar/fire1/GPUParticles2D
@onready var fire_particles_two: GPUParticles2D = $VBoxContainer/XP/ProgressBar/fire2/GPUParticles2D

@onready var xp_label: Label = $VBoxContainer/XP/HBoxContainer/xpLabel
@onready var level_label: Label = $VBoxContainer/XP/HBoxContainer/levelLabel
@onready var reset_button: Button = $VBoxContainer/CenterContainer/resetButton


func _ready():
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	load_checkbox_state()
	connect_checkboxes()
	fireworks_timer.timeout.connect(stop_fireworks)
	load_experience_progress()
	update_progress()
	stop_fireworks()

func _exit_tree():
	save_checkbox_state()
	save_experioence_progress()


func load_experience_progress():
	if cfg.load(CONFIG_PATH) == OK:
		level = cfg.get_value("xp", "level", 1)
		xp = cfg.get_value("xp", "xp", 0)
	else:
		level = 1
		xp = 0
	
	xp_next = 2 * BASE_XP
	progress.max_value = xp_next
	
	for i in range(2, level + 1):
		xp_next += round(BASE_XP * i / 10.0) * 10
		progress.max_value = round(BASE_XP * level / 10.0) * 10
	
	progress.value = xp - (xp_next - progress.max_value)

func save_experioence_progress():
	cfg.set_value("xp", "level", level)
	cfg.set_value("xp", "xp", xp)
	cfg.save(CONFIG_PATH)


func _on_typing():
	xp += 1
	progress.value += 1
	
	if progress.value >= progress.max_value:
		level += 1
		xp_next = xp + round(BASE_XP * level / 10.0) * 10
		progress.value = 0
		progress.max_value = xp_next - xp
		
		if fireworks: 
			start_fireworks()
	
	update_progress()


func start_fireworks():
	sfx_fireworks.play()
	fireworks_timer.start()
	
	fire_particles_one.emitting = true
	fire_particles_two.emitting = true

func stop_fireworks():
	fire_particles_one.emitting = false
	fire_particles_two.emitting = false


func update_progress():
	xp_label.text = "XP: %d / %d" % [ xp, xp_next ]
	level_label.text = "Level: %d" % level


func connect_checkboxes():
	for checkbox in [explosion_checkbox, blip_checkbox, chars_checkbox, 
					shake_checkbox, sound_checkbox, fireworks_checkbox]:
		checkbox.toggled.connect(_on_checkbox_toggled.bind(checkbox))

func _on_checkbox_toggled(toggled: bool, which: CheckButton):
	match which:
		explosion_checkbox: explosions = toggled
		blip_checkbox: blips = toggled
		chars_checkbox: chars = toggled
		shake_checkbox: shake = toggled
		sound_checkbox: sound = toggled
		fireworks_checkbox: fireworks = toggled
	save_checkbox_state()

func save_checkbox_state():
	cfg.set_value("settings", "explosion", explosions)
	cfg.set_value("settings", "blips", blips)
	cfg.set_value("settings", "chars", chars)
	cfg.set_value("settings", "shake", shake)
	cfg.set_value("settings", "sound", sound)
	cfg.set_value("settings", "fireworks", fireworks)
	cfg.save(CONFIG_PATH)

func load_checkbox_state():
	if cfg.load(CONFIG_PATH) == OK:
		explosion_checkbox.set_pressed_no_signal(cfg.get_value("settings", "explosion", true))
		blip_checkbox.set_pressed_no_signal(cfg.get_value("settings", "blips", true))
		chars_checkbox.set_pressed_no_signal(cfg.get_value("settings", "chars", true))
		shake_checkbox.set_pressed_no_signal(cfg.get_value("settings", "shake", true))
		sound_checkbox.set_pressed_no_signal(cfg.get_value("settings", "sound", true))
		fireworks_checkbox.set_pressed_no_signal(cfg.get_value("settings", "fireworks", true))
		explosions = explosion_checkbox.button_pressed
		blips = blip_checkbox.button_pressed
		chars = chars_checkbox.button_pressed
		shake = shake_checkbox.button_pressed
		sound = sound_checkbox.button_pressed
		fireworks = fireworks_checkbox.button_pressed
	else:
		explosion_checkbox.button_pressed = explosions
		blip_checkbox.button_pressed = blips
		chars_checkbox.button_pressed = chars
		shake_checkbox.button_pressed = shake
		sound_checkbox.button_pressed = sound
		fireworks_checkbox.button_pressed = fireworks


func _on_reset_button_pressed():
	level = 1
	xp = 0
	xp_next = 2 * BASE_XP
	progress.value = 0
	progress.max_value = xp_next
	update_progress()

