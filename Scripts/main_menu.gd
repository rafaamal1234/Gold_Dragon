extends Control

const SAVE_PATH := "user://save.cfg"

func _on_play_pressed():
	var config := ConfigFile.new()
	var story_seen := false
	if config.load(SAVE_PATH) == OK:
		story_seen = config.get_value("progress", "story_seen", false)

	if story_seen:
		get_tree().change_scene_to_file("res://scenes/world_map.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/story.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_exit_pressed():
	get_tree().quit()
