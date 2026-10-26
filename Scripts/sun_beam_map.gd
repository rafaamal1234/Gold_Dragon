extends Node2D

const SAVE_PATH := "user://save.cfg"

const LEVEL_SCENES := {
	1: "res://scenes/levels/level_1.tscn",
	2: "res://scenes/levels/level_2.tscn",
	3: "res://scenes/levels/level_3.tscn",
	4: "res://scenes/levels/level_4.tscn",
	5: "res://scenes/levels/level_5.tscn",
}

@export_file("*.tscn") var back_scene: String = "res://scenes/world_map.tscn"
@export var scroll_speed := 600.0     # arrow keys / WASD
@export var wheel_step := 120.0       # mouse wheel

@onready var camera: Camera2D = $Camera2D
@onready var background: Sprite2D = $Background

var map_size := Vector2.ZERO
var unlocked_levels := 1
var dragging := false

func _ready():
	map_size = background.texture.get_size() * background.scale

	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		unlocked_levels = config.get_value("progress", "sunbeam_levels_unlocked", 1)

	for button in $Levels.get_children():
		var level := int(button.name.trim_prefix("Level"))
		var unlocked := level <= unlocked_levels
		button.disabled = not unlocked
		if button.has_node("LockIcon"):
			button.get_node("LockIcon").visible = not unlocked
		if unlocked:
			button.pressed.connect(_on_level_pressed.bind(level))

	$UI/BackButton.pressed.connect(_on_back_pressed)

	# Start the camera on the latest unlocked level
	var focus := $Levels.get_node_or_null("Level%d" % unlocked_levels)
	if focus:
		camera.position = focus.position + focus.size / 2.0
	camera.reset_smoothing()
	_clamp_camera()

func _process(delta):
	# Arrow keys / WASD scrolling
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir != Vector2.ZERO:
		camera.position += dir * scroll_speed * delta
		_clamp_camera()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.y -= wheel_step
			_clamp_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.y += wheel_step
			_clamp_camera()
	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative / camera.zoom
		_clamp_camera()

func _clamp_camera():
	var half := get_viewport_rect().size / camera.zoom / 2.0
	camera.position.x = clampf(camera.position.x, half.x, maxf(half.x, map_size.x - half.x))
	camera.position.y = clampf(camera.position.y, half.y, maxf(half.y, map_size.y - half.y))

func _on_level_pressed(level: int):
	SceneLoader.go_to(LEVEL_SCENES[level])

func _on_back_pressed():
	get_tree().change_scene_to_file(back_scene)
