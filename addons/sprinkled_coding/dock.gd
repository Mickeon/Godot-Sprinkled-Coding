@tool
@static_unload
extends Control

const CONFIG_PATH = "user://sprinkled_coding.cfg"

static var explosions := true
static var blips := true
static var chars := true
static var sound := true

var cfg := ConfigFile.new()

@export var explosion_checkbox: CheckButton
@export var blip_checkbox: CheckButton
@export var chars_checkbox: CheckButton
@export var sound_checkbox: CheckButton

func _ready():
	load_checkbox_state()
	connect_checkboxes()

func _exit_tree():
	save_checkbox_state()



func connect_checkboxes():
	for checkbox in [explosion_checkbox, blip_checkbox, chars_checkbox, sound_checkbox,]:
		checkbox.toggled.connect(_on_checkbox_toggled.bind(checkbox))

func _on_checkbox_toggled(toggled: bool, which: CheckButton):
	match which:
		explosion_checkbox: explosions = toggled
		blip_checkbox: blips = toggled
		chars_checkbox: chars = toggled
		sound_checkbox: sound = toggled
	save_checkbox_state()

func save_checkbox_state():
	cfg.set_value("settings", "explosion", explosions)
	cfg.set_value("settings", "blips", blips)
	cfg.set_value("settings", "chars", chars)
	cfg.set_value("settings", "sound", sound)
	cfg.save(CONFIG_PATH)

func load_checkbox_state():
	if cfg.load(CONFIG_PATH) == OK:
		explosions = cfg.get_value("settings", "explosion", true)
		blips = cfg.get_value("settings", "blips", true)
		chars = cfg.get_value("settings", "chars", true)
		sound = cfg.get_value("settings", "sound", true)
	
	explosion_checkbox.set_pressed_no_signal(explosions)
	blip_checkbox.set_pressed_no_signal(blips)
	chars_checkbox.set_pressed_no_signal(chars)
	sound_checkbox.set_pressed_no_signal(sound)

