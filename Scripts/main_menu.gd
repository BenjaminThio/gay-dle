extends Node2D

func play() -> void:
	get_tree().change_scene_to_file("res://Scenes/battlefield.tscn")

func exit() -> void:
	get_tree().quit()
