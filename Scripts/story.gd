extends Control

const SAVE_PATH := "user://save.cfg"

@export var backgrounds: Array[Texture2D]
@export_multiline var texts: Array[String]
@export_file("*.tscn") var next_scene: String = "res://scenes/main_menu.tscn"

@onready var background: TextureRect = $Background
@onready var story_text: Label = $TextPanel/StoryText

var index := 0
var tween: Tween

func _ready():
	show_panel()

func show_panel():
	background.texture = backgrounds[index]
	story_text.text = texts[index] if index < texts.size() else ""
	story_text.visible_ratio = 0.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(story_text, "visible_ratio", 1.0, 1.5)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If the text is still typing, the first click finishes it
		if tween and tween.is_running():
			tween.kill()
			story_text.visible_ratio = 1.0
			return
		index += 1
		if index < backgrounds.size():
			show_panel()
		else:
			mark_story_seen()
			get_tree().change_scene_to_file(next_scene)

func mark_story_seen():
	var config := ConfigFile.new()
	config.load(SAVE_PATH)  # keeps any other saved data
	config.set_value("progress", "story_seen", true)
	config.save(SAVE_PATH)
