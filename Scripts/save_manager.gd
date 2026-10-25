extends Node

const SAVE_PATH := "user://save.cfg"

func unlock_next_kingdom(current_count: int):
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	var saved: int = config.get_value("progress", "kingdoms_unlocked", 1)
	config.set_value("progress", "kingdoms_unlocked", max(saved, current_count + 1))
	config.save(SAVE_PATH)
