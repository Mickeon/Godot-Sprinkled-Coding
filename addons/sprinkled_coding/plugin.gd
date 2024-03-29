@tool
extends EditorPlugin

signal typing

# Scripts.
const BoomEffect = preload("effects/boom.gd")
const BlipEffect = preload("effects/blip.gd")
const NewlineEffect = preload("effects/newline.gd")
const SprinkleSettingsDock = preload("dock.gd")

# Packed Scenes.
const BoomScene = preload("effects/Boom.tscn")
const BlipScene = preload("effects/Blip.tscn")
const NewlineScene = preload("effects/Newline.tscn")
const DockScene = preload("Dock.tscn")

const PITCH_DECREMENT = 0.05

var time_since_last_effect := 0.0
var last_key := ""
var strength_increase := 0.0:
	set(new):
		strength_increase = clamp(new, 0.0, 1.0)

var editors := {} ## Contains cached references to TextEdits.
var dock: SprinkleSettingsDock


func _enter_tree():
	var script_editor := EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(find_all_text_editors.unbind(1))

	# Add the main panel.
	dock = DockScene.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	find_all_text_editors()

func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.free()

func _process(delta):
	time_since_last_effect += delta
	if (strength_increase > 0.0):
		strength_increase -= delta * PITCH_DECREMENT


func try_to_emit_effects(textedit: TextEdit, caret_index := 0):
	var line_height := textedit.get_line_height()
	var pos := textedit.get_caret_draw_pos(caret_index) + Vector2(0, line_height * -0.5)
	var color := _get_caret_highlight_color(textedit, caret_index)
	
	# Deleting.
	if time_since_last_effect > 0.1 and len(textedit.text) < len(editors[textedit]["text"]):
		set_deferred("time_since_last_effect", 0.0)
		
		if dock.explosions:
			var effect: BoomEffect = BoomScene.instantiate()
			effect.position = pos
			effect.modulate = color
			if dock.chars and textedit.get_caret_count() == 1:
				effect.key = last_key
			textedit.add_child(effect)
			
			strength_increase = strength_increase - 0.01
	
	# Typing.
	if time_since_last_effect > 0.02 and len(textedit.text) >= len(editors[textedit]["text"]):
		if last_key == "Space":
			return
#		time_since_last_effect = 0.0
		set_deferred("time_since_last_effect", 0.0)
		
		var effect: BlipEffect = BlipScene.instantiate()
		effect.position = pos
		effect.modulate = color
		effect.pitch_increase = strength_increase + caret_index * -0.12
		
		if dock.chars and textedit.get_caret_count() == 1:
			effect.key = last_key
		
		textedit.add_child(effect)
		strength_increase += 0.01 / (caret_index + 1)
		
	# Newline.
	if textedit.get_caret_line(caret_index) != editors[textedit]["line"]:
		var effect: NewlineEffect = NewlineScene.instantiate()
		effect.position = pos
		effect.modulate = color
		textedit.add_child(effect)

func find_all_text_editors():
	editors.clear()
	_recursive_find_text_editors(EditorInterface.get_script_editor())

func _recursive_find_text_editors(parent: Node):
	for child in parent.get_children():
		if child.get_child_count() > 0:
			_recursive_find_text_editors(child)
			
		if child is TextEdit:
			editors[child] = { 
				"text": child.text, 
				"line": child.get_caret_line() 
			}
			
			if child.caret_changed.is_connected(_on_caret_changed):
				child.caret_changed.disconnect(_on_caret_changed)
			child.caret_changed.connect(_on_caret_changed.bind(child))
			
			if child.text_changed.is_connected(_on_text_changed):
				child.text_changed.disconnect(_on_text_changed)
			child.text_changed.connect(_on_text_changed.bind(child))
			
			if child.gui_input.is_connected(_on_gui_input):
				child.gui_input.disconnect(_on_gui_input)
			child.gui_input.connect(_on_gui_input.bind(child))


func _on_gui_input(event: InputEvent, textedit: TextEdit):
	# Get last typed key.
	if event is InputEventKey and event.pressed:
		last_key = OS.get_keycode_string(event.get_keycode_with_modifiers())
		# HACK: Prepare to tackle letter about to be deleted
		if event.keycode == KEY_BACKSPACE:
			
			var line_text = "".join(textedit.get_line_wrapped_text(textedit.get_caret_line()))
			last_key = line_text[textedit.get_caret_column() - 1]

func _on_caret_changed(textedit: TextEdit):
	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them.
		find_all_text_editors()
		
	editors[textedit]["line"] = textedit.get_caret_line()

func _on_text_changed(textedit: TextEdit):
	typing.emit()
	
	if editors.has(textedit):
		for caret in textedit.get_caret_count():
			try_to_emit_effects(textedit, caret)
	
	editors[textedit]["text"] = textedit.text
	editors[textedit]["line"] = textedit.get_caret_line()


static func _get_caret_highlight_color(textedit: TextEdit, caret_index := 0) -> Color:
	var caret_line := textedit.get_caret_line(caret_index)
	var caret_column := textedit.get_caret_column(caret_index)
	
	var line_highlighting := textedit.syntax_highlighter.get_line_syntax_highlighting(caret_line)
	var color := textedit.get_theme_color("font_color") #Color.WHITE
	for column_pos in line_highlighting:
		if column_pos <= caret_column:
			color = line_highlighting[column_pos]["color"]
		else:
			return color
	return color

