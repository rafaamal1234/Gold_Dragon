extends Control

@export var min_time := 2.0   # how long the loading screen stays visible

@onready var dots: Array[Control] = [$Dots/Dot1, $Dots/Dot2, $Dots/Dot3]

var target_path := ""
var elapsed := 0.0

func _ready() -> void:
	_animate_dots()
	target_path = SceneLoader.target_scene
	ResourceLoader.load_threaded_request(target_path)

func _process(delta: float) -> void:
	elapsed += delta
	var status := ResourceLoader.load_threaded_get_status(target_path)

	if status == ResourceLoader.THREAD_LOAD_LOADED and elapsed >= min_time:
		var scene: PackedScene = ResourceLoader.load_threaded_get(target_path)
		set_process(false)
		get_tree().change_scene_to_packed(scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Could not load: " + target_path)
		set_process(false)

func _animate_dots() -> void:
	var tween := create_tween().set_loops()
	tween.tween_callback(func(): for d in dots: d.modulate.a = 0.0)
	for d in dots:
		tween.tween_interval(0.4)
		tween.tween_property(d, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.5)
