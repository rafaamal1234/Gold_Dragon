extends Control

const SAVE_PATH := "user://save.cfg"

# Order matters: the first N kingdoms are unlocked
const KINGDOM_ORDER := ["SunBeam Kingdom", "Enchanted Forest"]

# Scenes to open when a kingdom is clicked (create these later)
const KINGDOM_SCENES := {
	"SunBeam Kingdom": "res://Scenes/sun_beam_map.tscn",
	"Enchanted Forest": "res://scenes/kingdom_enchantedforest.tscn",
}

func _ready():
	$BackButton.pressed.connect(_on_back_pressed)
	var unlocked := load_unlocked_count()
	for i in KINGDOM_ORDER.size():
		var kingdom_name: String = KINGDOM_ORDER[i]
		var button: TextureButton = $Kingdoms.get_node(kingdom_name)
		var is_unlocked := i < unlocked

		button.disabled = not is_unlocked
		button.get_node("LockIcon").visible = not is_unlocked
		# self_modulate dims only the button, not the lock icon or label
		button.self_modulate = Color.WHITE if is_unlocked else Color(0.5, 0.5, 0.5)

		if is_unlocked:
			button.pressed.connect(_on_kingdom_pressed.bind(kingdom_name))
			button.mouse_entered.connect(_on_hover.bind(button, true))
			button.mouse_exited.connect(_on_hover.bind(button, false))

func load_unlocked_count() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		return config.get_value("progress", "kingdoms_unlocked", 1)
	return 1  # first launch: only Sunnyvale is open

func _on_kingdom_pressed(kingdom_name: String):
	get_tree().change_scene_to_file(KINGDOM_SCENES[kingdom_name])

func _on_hover(button: TextureButton, hovering: bool):
	button.pivot_offset = button.size / 2.0
	var target := Vector2(1.08, 1.08) if hovering else Vector2.ONE
	create_tween().tween_property(button, "scale", target, 0.1)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
