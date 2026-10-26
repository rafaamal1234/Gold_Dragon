extends Node

var target_scene := ""

func go_to(path: String):
	target_scene = path
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")
