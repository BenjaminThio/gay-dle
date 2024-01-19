extends Control

var victory_sound: AudioStreamOggVorbis = preload("res://Musics/victory.ogg")
var defeat_sound: AudioStreamOggVorbis = preload("res://Musics/defeat.ogg")

@onready var title: Label = $Title
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if Global.victory:
		audio_player.stream = victory_sound
	else:
		audio_player.stream = defeat_sound
	audio_player.play()
	
	title.text = ["Defeat...", "Victory!"][int(Global.victory)]

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/battlefield.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
