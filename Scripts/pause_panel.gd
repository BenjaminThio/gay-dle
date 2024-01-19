extends Panel

func resume() -> void:
	get_tree().paused = false
	hide()

func restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/battlefield.tscn")

func main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
